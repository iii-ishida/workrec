defmodule Workrec.Repositories.CloudDatastore do
  @moduledoc """
  Cloud Datastore repository
  """

  alias DsWrapper.Connection
  alias DsWrapper.Datastore
  alias DsWrapper.Key

  alias Workrec.Event
  alias Workrec.Repositories.CloudDatastore.Entity.Decoder
  alias Workrec.TaskList
  alias Workrec.TaskListItem

  defstruct [:connection]

  def new do
    with {:ok, connection} <- Connection.new() do
      {:ok, %__MODULE__{connection: connection}}
    end
  end

  def run_in_transaction(%{connection: connection}, fun) do
    Datastore.run_in_transaction(connection, fn tx ->
      fun.(%__MODULE__{connection: tx})
    end)
  end

  def run_in_transaction(fun) do
    case new() do
      {:ok, repo} -> run_in_transaction(repo, fun)
      error -> error
    end
  end

  def find(%{connection: connection}, module, id) do
    with {:ok, found} <- Datastore.find(connection, Key.new(module.kind_name(), id)) do
      case found do
        nil -> {:ok, nil}
        found -> {:ok, module.from_entity(found)}
      end
    end
  end

  def find!(connection, module, id) do
    case find(connection, module, id) do
      {:ok, found} -> found
      {:error, reason} -> raise reason
    end
  end

  def insert(%{connection: connection}, models) do
    entity = Decoder.to_entity(models)
    Datastore.insert(connection, entity)
  end

  def insert!(repo, models) do
    case insert(repo, models) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  def upsert(%{connection: connection}, models) do
    entity = Decoder.to_entity(models)
    Datastore.upsert(connection, entity)
  end

  def upsert!(repo, models) do
    case upsert(repo, models) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  def update(%{connection: connection}, models) do
    entity = Decoder.to_entity(models)
    Datastore.update(connection, entity)
  end

  def update!(repo, models) do
    case update(repo, models) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  def delete(%{connection: connection}, models) when is_list(models) do
    keys = Enum.map(models, &Key.new(&1.__struct__.kind_name, &1.id))
    Datastore.delete(connection, keys)
  end

  def delete(%{connection: connection}, model) do
    delete(connection, [model])
  end

  def delete!(repo, models) do
    case delete(repo, models) do
      :ok -> :ok
      {:error, reason} -> raise reason
    end
  end

  def list_events(%{connection: connection}, user_id, created_at, limit \\ 100, page_token \\ "") do
    import DsWrapper.Query

    query =
      Datastore.query(Event.kind_name())
      |> where("user_id", "=", user_id)
      |> where("created_at", ">", created_at)
      |> order("user_id")
      |> order("created_at")
      |> limit(limit)
      |> start(page_token)

    with {:ok, result} <- Datastore.run_query(connection, query) do
      {:ok, Enum.map(result.entities, &Event.from_entity/1)}
    end
  end

  def list_events!(repo, user_id, created_at, limit \\ 100, page_token \\ "") do
    case list_events(repo, user_id, created_at, limit, page_token) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  def find_last_event(%{connection: connection}, user_id, task_id) do
    import DsWrapper.Query

    query =
      Datastore.query(Event.kind_name())
      |> where("user_id", "=", user_id)
      |> where("task_id", "=", task_id)
      |> order("user_id")
      |> order("task_id")
      |> order("created_at", :desc)
      |> limit(1)

    case Datastore.run_query(connection, query) do
      {:ok, %{entities: []}} -> {:ok, nil}
      {:ok, %{entities: [entity | _]}} -> {:ok, Event.from_entity(entity)}
      error -> error
    end
  end

  def find_last_event!(repo, user_id, task_id) do
    case find_last_event(repo, user_id, task_id) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  def list_tasks(%{connection: connection}, user_id, limit \\ 100, page_token \\ "") do
    import DsWrapper.Query

    query =
      Datastore.query(TaskListItem.kind_name())
      |> where("user_id", "=", user_id)
      |> order("user_id")
      |> order("created_at", :desc)
      |> limit(limit)
      |> start(page_token)

    with {:ok, result} <- Datastore.run_query(connection, query) do
      {:ok, TaskList.from_entity(result)}
    end
  end
end

defmodule Workrec.Repositories.CloudDatastore.EntityModel do
  @moduledoc """
  behaviour for Entity <-> Model
  """

  @callback kind_name() :: String.t()
  @callback from_entity(%{properties: map}) :: struct
end

defprotocol Workrec.Repositories.CloudDatastore.Entity.Decoder do
  def to_entity(value)
end

defimpl Workrec.Repositories.CloudDatastore.Entity.Decoder, for: List do
  def to_entity(value) do
    Enum.map(value, &Workrec.Repositories.CloudDatastore.Entity.Decoder.to_entity(&1))
  end
end
