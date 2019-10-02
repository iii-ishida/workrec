defmodule Workrec.Repositories.CloudDatastore do
  alias Utils.Datastore
  alias Utils.Datastore.Entity.Decoder

  defstruct [:store]

  def new() do
    %__MODULE__{store: Datastore.new()}
  end

  def add_mutations(%{store: tx}, mutations) do
    %__MODULE__{store: Utils.Datastore.Transaction.add_mutations(tx, mutations)}
  end

  def transaction(%{store: repo}) do
    with {:ok, tx} <- Datastore.transaction(repo) do
      {:ok, %__MODULE__{store: tx}}
    end
  end

  def transaction() do
    transaction(new())
  end

  def commit(%{store: tx}), do: Utils.Datastore.commit(tx)

  # def transaction(%{store: repo}, fun) do
  #   with {:ok, tx} <- Datastore.transaction(repo) do
  #     tx = fun.(%__MODULE__{store: tx})
  #       Logger.info(inspect tx)
  #       Datastore.commit(tx)
  #   else 
  #     err ->
  #       Logger.info("ERR")
  #       Logger.info(inspect(err))
  #       {:error}
  #   end
  # end

  def find(%{store: repo_or_tx}, module, id) do
    with {:ok, found} <- Datastore.find(repo_or_tx, Datastore.new_key(module.kind_name(), id)) do
      found =
        case found do
          nil -> nil
          found -> module.from_entity(found)
        end

      {:ok, found}
    end
  end

  def find!(store, module, id) do
    with {:ok, found} <- find(store, module, id) do
      found
    else
      {:error, reason} -> raise reason
    end
  end

  def insert_mutation(value) do
    entity = Decoder.to_entity(value)
    Datastore.insert_mutation(entity)
  end

  def upsert_mutation(value) do
    entity = Decoder.to_entity(value)
    Datastore.upsert_mutation(entity)
  end

  def delete_mutation(kind, id) do
    Datastore.delete_mutation(Datastore.new_key(kind, id))
  end

  def insert(%{store: repo_or_tx}, value) do
    entity = Decoder.to_entity(value)
    Datastore.insert(repo_or_tx, entity)
  end

  def upsert(%{store: repo_or_tx}, value) do
    entity = Decoder.to_entity(value)
    Datastore.upsert(repo_or_tx, entity)
  end

  def delete(%{store: repo_or_tx}, kind, id) do
    Datastore.delete(repo_or_tx, Datastore.new_key(kind, id))
  end

  def list_events(%{store: repo_or_tx}, user_id, created_at, limit \\ 100, page_token \\ "") do
    query =
      Datastore.new_query(Workrec.Event.kind_name())
      |> Datastore.where("user_id", "=", user_id)
      |> Datastore.where("created_at", ">", created_at)
      |> Datastore.order("user_id")
      |> Datastore.order("created_at")
      |> Datastore.limit(limit)
      |> Datastore.start(page_token)

    with {:ok, result} <- Datastore.run_query(repo_or_tx, query) do
      {:ok, Enum.map(result.entities, &Workrec.Event.from_entity/1)}
    end
  end

  def find_last_event(%{store: repo_or_tx}, user_id, work_id) do
    query =
      Datastore.new_query(Workrec.Event.kind_name())
      |> Datastore.where("user_id", "=", user_id)
      |> Datastore.where("work_id", "=", work_id)
      |> Datastore.order("user_id")
      |> Datastore.order("work_id")
      |> Datastore.order("created_at", :desc)
      |> Datastore.limit(1)

    case Datastore.run_query(repo_or_tx, query) do
      {:ok, %{entities: []}} -> {:ok, nil}
      {:ok, %{entities: [entity | _]}} -> {:ok, Workrec.Event.from_entity(entity)}
      error -> error
    end
  end

  def list_works(%{store: repo_or_tx}, user_id, limit \\ 100, page_token \\ "") do
    query =
      Datastore.new_query(Workrec.WorkListItem.kind_name())
      |> Datastore.where("user_id", "=", user_id)
      |> Datastore.order("user_id")
      |> Datastore.order("created_at", :desc)
      |> Datastore.limit(limit)
      |> Datastore.start(page_token)

    with {:ok, result} <- Datastore.run_query(repo_or_tx, query) do
      {:ok, Workrec.WorkList.from_entity(result)}
    end
  end
end
