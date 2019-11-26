defmodule Utils.DatastoreHelper do
  @moduledoc """
  Helper for Cloud Datastore
  """

  alias GoogleApi.Datastore.V1.Api.Projects
  alias GoogleApi.Datastore.V1.Connection

  alias GoogleApi.Datastore.V1.Model.{
    BeginTransactionRequest,
    CommitRequest,
    CommitResponse,
    Key,
    LookupRequest,
    Mutation,
    Query,
    ReadOptions,
    ReadWrite,
    RollbackRequest,
    RollbackResponse,
    RunQueryRequest,
    TransactionOptions
  }

  alias Utils.DatastoreHelper.Entity
  alias Utils.DatastoreHelper.Transaction

  defstruct connection: nil

  @type t :: %__MODULE__{connection: Tesla.Client.t()}

  @type entity :: GoogleApi.Datastore.V1.Model.Entity.t()

  @spec new() :: {:ok, t} | {:error, term}
  def new do
    case Goth.Token.for_scope("https://www.googleapis.com/auth/datastore") do
      {:ok, token} -> {:ok, %__MODULE__{connection: Connection.new(token.token)}}
      error -> error
    end
  end

  @spec new!() :: t | no_return
  def new!() do
    case new() do
      {:ok, store} -> store
      {:error, reason} -> raise reason
    end
  end

  @spec run_in_transaction(t, (Transaction.t() -> term)) :: {:ok, term} | {:error, term}
  def run_in_transaction(%{connection: conn} = store, fun) do
    tx_id = begin_transaction!(store)

    tx = Transaction.new!(conn, tx_id)

    try do
      result = fun.(tx)
      commit(tx)
      {:ok, result}
    rescue
      e ->
        rollback(tx)
        {:error, e}
    end
  end

  defp begin_transaction!(%{connection: conn}) do
    req = %BeginTransactionRequest{
      transactionOptions: %TransactionOptions{readWrite: %ReadWrite{}}
    }

    case call_datastore_api(conn, &Projects.datastore_projects_begin_transaction/3, body: req) do
      {:ok, %{transaction: transaction}} -> transaction
      {:error, reason} -> raise reason
    end
  end

  @spec find(t, %Key{}) :: {:ok, map | nil} | {:error, term}
  def find(store, key) do
    lookup(store, [key])
  end

  @spec run_query(t, Query.t()) :: {:ok, %{cursor: String.t(), entities: list(term)}} | {:error, term}
  def run_query(%{connection: conn}, query) do
    req = %RunQueryRequest{query: query, readOptions: %ReadOptions{}}

    with {:ok, result} <- call_datastore_api(conn, &Projects.datastore_projects_run_query/3, body: req) do
      cursor = result.batch.endCursor
      entity_results = result.batch.entityResults || []
      entities = Enum.map(entity_results, &Entity.to_map/1)
      {:ok, %{cursor: cursor, entities: entities}}
    end
  end

  @spec insert(Transaction.t(), list(entity) | entity) :: {:ok, nil}
  def insert(%Transaction{} = tx, entity) do
    Transaction.insert(tx, insert_mutations(entity))
    {:ok, nil}
  end

  @spec insert(t, list(entity) | entity) :: {:ok, CommitResponse.t()} | {:error, term}
  def insert(store, entity) do
    commit(store, insert_mutations(entity))
  end

  @spec update(Transaction.t(), list(entity) | entity) :: {:ok, nil}
  def update(%Transaction{} = tx, entity) do
    Transaction.update(tx, update_mutations(entity))
    {:ok, nil}
  end

  @spec update(t, list(entity) | entity) :: {:ok, CommitResponse.t()} | {:error, term}
  def update(store, entity) do
    commit(store, update_mutations(entity))
  end

  @spec upsert(Transaction.t(), list(entity) | entity) :: {:ok, nil}
  def upsert(%Transaction{} = tx, entity) do
    Transaction.upsert(tx, upsert_mutations(entity))
    {:ok, nil}
  end

  @spec upsert(t, list(entity) | entity) :: {:ok, CommitResponse.t()} | {:error, term}
  def upsert(store, entity) do
    commit(store, upsert_mutations(entity))
  end

  @spec delete(Transaction.t(), list(%Key{}) | %Key{}) :: {:ok, nil}
  def delete(%Transaction{} = tx, key) do
    Transaction.delete(tx, delete_mutations(key))
    {:ok, nil}
  end

  @spec delete(t, list(%Key{}) | %Key{}) :: {:ok, CommitResponse.t()} | {:error, term}
  def delete(store, key) do
    commit(store, delete_mutations(key))
  end

  defp insert_mutations(entities) when is_list(entities) do
    Enum.map(entities, &%Mutation{insert: &1})
  end

  defp insert_mutations(entity) do
    insert_mutations([entity])
  end

  defp upsert_mutations(entities) when is_list(entities) do
    Enum.map(entities, &%Mutation{upsert: &1})
  end

  defp upsert_mutations(entity) do
    upsert_mutations([entity])
  end

  defp update_mutations(entities) when is_list(entities) do
    Enum.map(entities, &%Mutation{update: &1})
  end

  defp update_mutations(entity) do
    update_mutations([entity])
  end

  defp delete_mutations(keys) when is_list(keys) do
    Enum.map(keys, &%Mutation{delete: &1})
  end

  defp delete_mutations(key) do
    delete_mutations([key])
  end

  def commit(%Transaction{} = tx) do
    req = %CommitRequest{
      mode: "TRANSACTIONAL",
      mutations: Transaction.mutations(tx),
      transaction: tx.id
    }

    Transaction.stop(tx)

    call_datastore_api(tx.connection, &Projects.datastore_projects_commit/3, body: req)
  end

  def commit(%{connection: conn}, mutations) do
    req = %CommitRequest{
      mode: "NON_TRANSACTIONAL",
      mutations: mutations
    }

    call_datastore_api(conn, &Projects.datastore_projects_commit/3, body: req)
  end

  @spec rollback(Transaction.t()) :: {:ok, RollbackResponse.t()} | {:error, term}
  def rollback(%Transaction{} = tx) do
    req = %RollbackRequest{transaction: tx.id}
    Transaction.stop(tx)

    call_datastore_api(tx.connection, &Projects.datastore_projects_rollback/3, body: req)
  end

  defp lookup(%{connection: conn} = store, keys) do
    req = %LookupRequest{
      keys: keys,
      readOptions: %ReadOptions{transaction: Map.get(store, :id)}
    }

    with {:ok, result} <- call_datastore_api(conn, &Projects.datastore_projects_lookup/3, body: req) do
      found = List.first(result.found || [])
      {:ok, Entity.to_map(found)}
    end
  end

  defp call_datastore_api(conn, fun, optional_params) do
    case fun.(conn, project_id(), optional_params) do
      {:ok, _} = result -> result
      {:error, _} = error -> error
      reason -> {:error, reason}
    end
  end

  defp project_id, do: System.get_env("GOOGLE_CLOUD_PROJECT")
end
