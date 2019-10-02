defmodule Utils.Datastore.Transaction do
  defstruct connection: nil, id: "", mutations: []

  def add_mutations(tx, mutations) when is_list(mutations) do
    %__MODULE__{tx | mutations: tx.mutations ++ mutations}
  end

  def add_mutations(tx, mutation) do
    add_mutations(tx, [mutation])
  end
end

defmodule Utils.Datastore do
  alias Utils.Datastore.Transaction
  alias GoogleApi.Datastore.V1.Api.Projects

  alias GoogleApi.Datastore.V1.Model.{
    ArrayValue,
    BeginTransactionRequest,
    CommitRequest,
    CompositeFilter,
    Entity,
    EntityResult,
    Filter,
    Key,
    KindExpression,
    LookupRequest,
    Mutation,
    PathElement,
    PropertyFilter,
    PropertyOrder,
    PropertyReference,
    Query,
    ReadOptions,
    ReadWrite,
    RollbackRequest,
    RunQueryRequest,
    TransactionOptions,
    Value
  }

  defstruct [:connection]

  def new do
    with {:ok, token} <- Goth.Token.for_scope("https://www.googleapis.com/auth/datastore") do
      conn = GoogleApi.Datastore.V1.Connection.new(token.token)
      %__MODULE__{connection: conn}
    end
  end

  def new_key(parents \\ [], kind, name) do
    %Key{path: parents ++ [%PathElement{kind: kind, name: name}]}
  end

  def new_entity(key, properties) do
    %Entity{
      key: key,
      properties:
        Enum.reduce(properties, %{}, fn {k, v}, acc -> Map.merge(acc, %{k => to_value(v)}) end)
    }
  end

  def new_query(kind) do
    %Query{kind: %KindExpression{name: kind}}
  end

  def where(query, property, op, value) do
    composite_filter =
      case query.filter do
        %{compositeFilter: compositeFilter} -> compositeFilter
        _ -> %CompositeFilter{filters: [], op: "AND"}
      end

    filter = new_property_filter(property, op, value)

    composite_filter = %CompositeFilter{
      composite_filter
      | filters: composite_filter.filters ++ [filter]
    }

    %Query{query | filter: %Filter{compositeFilter: composite_filter}}
  end

  def order(query, property, direction \\ nil) do
    direction =
      case direction do
        :desc -> "DESCENDING"
        _ -> "ASCENDING"
      end

    %Query{query | order: (query.order || []) ++ [new_order(property, direction)]}
  end

  defp new_order(property, direction) do
    %PropertyOrder{property: to_property(property), direction: direction}
  end

  def limit(query, limit), do: %Query{query | limit: limit}

  def start(query, cursor), do: %Query{query | startCursor: cursor}

  defp to_property(property), do: %PropertyReference{name: property}

  defp to_op("="), do: "EQUAL"
  defp to_op("<"), do: "LESS_THAN"
  defp to_op("<="), do: "LESS_THAN_OR_EQUAL"
  defp to_op(">"), do: "GREATER_THAN"
  defp to_op(">="), do: "GREATER_THAN_OR_EQUAL"

  defp new_property_filter(property, op, value) do
    %Filter{
      propertyFilter: %PropertyFilter{
        property: to_property(property),
        op: to_op(op),
        value: to_value(value)
      }
    }
  end

  def find(repo_or_tx, key) do
    lookup(repo_or_tx, [key])
  end

  def run_query(repo_or_tx, query) do
    req = %RunQueryRequest{query: query, readOptions: %ReadOptions{}}

    with {:ok, result} <- call(repo_or_tx.connection, &Projects.datastore_projects_run_query/3, body: req),
         cursor = result.batch.endCursor,
         entity_results = result.batch.entityResults || [],
         entities = Enum.map(entity_results, &entity_to_map/1) do

      {:ok, %{cursor: cursor, entities: entities}}
    end
  end

  def insert_mutation(%Entity{} = e), do: %Mutation{insert: e}

  def insert(%Transaction{} = tx, entity) do
    Transaction.add_mutations(tx, insert_mutation(entity)) |> commit()
  end

  def insert(%__MODULE__{connection: conn}, entity) do
    insert(%Transaction{connection: conn}, entity)
  end

  def update_mutation(%Entity{} = e), do: %Mutation{update: e}

  def update(%Transaction{} = tx, entity) do
    Transaction.add_mutations(tx, update_mutation(entity)) |> commit()
  end

  def update(%__MODULE__{connection: conn}, entity) do
    update(%Transaction{connection: conn}, entity)
  end

  def upsert_mutation(%Entity{} = e), do: %Mutation{upsert: e}

  def upsert(%Transaction{} = tx, entity) do
    Transaction.add_mutations(tx, upsert_mutation(entity)) |> commit()
  end

  def upsert(%__MODULE__{connection: conn}, entity) do
    upsert(%Transaction{connection: conn}, entity)
  end

  def delete_mutation(%Key{} = key), do: %Mutation{delete: key}

  def delete(%Transaction{} = tx, key) do
    Transaction.add_mutations(tx, delete_mutation(key)) |> commit()
  end

  def delete(%__MODULE__{connection: conn}, key) do
    delete(%Transaction{connection: conn}, key)
  end

  def transaction(%__MODULE__{connection: conn}) do
    body = %BeginTransactionRequest{transactionOptions: %TransactionOptions{readWrite: %ReadWrite{}}}

    with {:ok, %{transaction: transaction}} <- call(conn, &Projects.datastore_projects_begin_transaction/3, body: body) do
      {:ok, %Transaction{connection: conn, id: transaction}}
    end
  end

  def transaction(nil) do
    transaction(new())
  end

  def commit(tx) do
    tx_id = case Map.get(tx, :id) do
      "" -> nil
      tx_id -> tx_id
    end

    req = %CommitRequest{
      mode: transaction_mode(tx_id),
      mutations: tx.mutations,
      transaction: tx_id,
    }

    call(tx.connection, &Projects.datastore_projects_commit/3, body: req)
  end

  defp transaction_mode(nil), do: "NON_TRANSACTIONAL"
  defp transaction_mode(_tx_id), do: "TRANSACTIONAL"

  def commit!(tx) do
    with {:ok, result} <- commit(tx) do
      result
    else
      {:error, reason} -> raise reason
    end
  end

  defp lookup(tx, keys) do
    req = %LookupRequest{
      keys: keys,
      readOptions: %ReadOptions{transaction: Map.get(tx, :id)}
    }

    with {:ok, result} <- call(tx.connection, &Projects.datastore_projects_lookup/3, body: req),
         found = List.first(result.found || []) do

      {:ok, entity_to_map(found)}
    end
  end

  def rollback(tx) do
    req = %RollbackRequest{transaction: tx.id}
    call(tx.connection, &Projects.datastore_projects_rollback/3, body: req)
  end

  defp call(conn, fun, optional_params) do
    with {:ok, result} <- fun.(conn, project_id(), optional_params) do
      {:ok, result}
    else
      {:error, reason} -> {:error, reason}
      reason -> {:error, reason}
      _ -> {:error, "UNKNOWN"}
    end
  end

  defp entity_to_map(%EntityResult{entity: entity}) do
    entity_to_map(entity)
  end

  defp entity_to_map(%Entity{} = entity) do
    %{
      key: entity.key,
      properties:
        Enum.reduce(entity.properties, %{}, fn {k, v}, acc ->
          Map.merge(acc, %{k => from_value(v)})
        end)
    }
  end

  defp entity_to_map(nil) do
    nil
  end

  defp to_value(%DateTime{} = value) do
    %Value{timestampValue: value}
  end

  defp to_value(value) when is_bitstring(value) do
    %Value{stringValue: value}
  end

  defp to_value(value) when is_nil(value) do
    %Value{nullValue: "NULL_VALUE"}
  end

  defp to_value(value) when is_integer(value) do
    %Value{integerValue: value}
  end

  defp to_value(value) when is_float(value) do
    %Value{doubleValue: value}
  end

  defp to_value(value) when is_boolean(value) do
    %Value{booleanValue: value}
  end

  defp to_value(value) when is_list(value) do
    values = value |> Enum.map(&to_value/1)
    %Value{arrayValue: %ArrayValue{values: values}}
  end

  defp from_value(%{integerValue: value}) when not is_nil(value) do
    value |> Integer.parse() |> elem(0)
  end

  defp from_value(%{integerValue: value}) when not is_nil(value) do
    value |> Integer.parse() |> elem(0)
  end

  defp from_value(%{arrayValue: value}) when not is_nil(value) do
    Enum.map(value.values, &from_value/1)
  end

  defp from_value(value) do
    case Map.from_struct(value) |> Enum.find(fn {_, v} -> v != nil end) do
      {_, v} -> v
      _ -> nil
    end
  end

  defp project_id, do: System.get_env("GOOGLE_CLOUD_PROJECT")
end

defprotocol Utils.Datastore.Entity.Decoder do
  def to_entity(value)
end
