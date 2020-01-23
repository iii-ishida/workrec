defmodule Workrec.Repository.CloudDatastore do
  @moduledoc """
  Cloud Datastore repository
  """

  alias DsWrapper.Connection
  alias DsWrapper.Datastore
  alias DsWrapper.Key

  alias Workrec.Model.{Event, Task, TaskAction, TaskActionList, TaskList}
  alias Workrec.Repository.CloudDatastore.Entity.Decoder

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

  def list_events!(%{connection: connection}, user_id, created_at, limit \\ 100, page_token \\ "") do
    import DsWrapper.Query

    query =
      Datastore.query(Event.kind_name())
      |> where("user_id", "=", user_id)
      |> where("created_at", ">", created_at)
      |> order("user_id")
      |> order("created_at")
      |> limit(limit)
      |> start(page_token)

    case Datastore.run_query(connection, query) do
      {:ok, found} -> Enum.map(found.results, fn %{entity: entity} -> Event.from_entity(entity) end)
      {:error, reason} -> raise reason
    end
  end

  def list_events_for_task!(%{connection: connection}, user_id, task_id, created_at, limit \\ 100, page_token \\ "") do
    import DsWrapper.Query

    query =
      Datastore.query(Event.kind_name())
      |> where("user_id", "=", user_id)
      |> where("task_id", "=", task_id)
      |> where("created_at", ">", created_at)
      |> order("user_id")
      |> order("task_id")
      |> order("created_at")
      |> limit(limit)
      |> start(page_token)

    case Datastore.run_query(connection, query) do
      {:ok, found} -> Enum.map(found.results, fn %{entity: entity} -> Event.from_entity(entity) end)
      {:error, reason} -> raise reason
    end
  end

  def list_events_for_task_actions!(%{connection: connection}, user_id, task_id, created_at, limit \\ 100, page_token \\ "") do
    import DsWrapper.Query

    query =
      Datastore.query(Event.kind_name())
      |> where("user_id", "=", user_id)
      |> where("task_id", "=", task_id)
      |> where("created_at", ">", created_at)
      |> order("user_id")
      |> order("task_id")
      |> order("created_at")
      |> limit(limit)
      |> start(page_token)

    case Datastore.run_query(connection, query) do
      {:ok, found} ->
        Enum.map(found.results, fn %{entity: entity} -> Event.from_entity(entity) end)
        |> Enum.filter(&(&1.task_action_id != nil))

      {:error, reason} ->
        raise reason
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
      {:ok, %{results: []}} -> {:ok, nil}
      {:ok, %{results: [result | _]}} -> {:ok, Event.from_entity(result.entity)}
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
      Datastore.query(Task.kind_name())
      |> where("user_id", "=", user_id)
      |> order("user_id")
      |> order("created_at", :desc)
      |> limit(limit)
      |> start(page_token)

    with {:ok, found} <- Datastore.run_query(connection, query),
         {:ok, has_next} <- has_next?(connection, query, found, limit) do
      cursor = if has_next, do: found.cursor, else: nil
      {:ok, TaskList.from_entity(found.results, cursor)}
    end
  end

  def list_task_actions(%{connection: connection}, user_id, task_id, limit \\ 100, page_token \\ "") do
    import DsWrapper.Query

    query =
      Datastore.query(TaskAction.kind_name())
      |> where("user_id", "=", user_id)
      |> where("task_id", "=", task_id)
      |> order("user_id")
      |> order("task_id")
      |> order("time")
      |> limit(limit)
      |> start(page_token)

    with {:ok, found} <- Datastore.run_query(connection, query),
         {:ok, has_next} <- has_next?(connection, query, found, limit) do
      cursor = if has_next, do: found.cursor, else: nil
      {:ok, TaskActionList.from_entity(found.results, cursor)}
    end
  end

  defp has_next?(_connection, _query, %{results: results}, limit) when length(results) < limit, do: {:ok, false}

  defp has_next?(connection, query, %{cursor: cursor}, _limit) do
    import DsWrapper.Query

    query_for_next = query |> start(cursor) |> limit(1)

    with {:ok, found} <- Datastore.run_query(connection, query_for_next) do
      {:ok, length(found.results) > 0}
    end
  end
end

defmodule Workrec.Repository.CloudDatastore.EntityModel do
  @moduledoc """
  behaviour for Entity <-> Model
  """

  @callback kind_name() :: String.t()
  @callback from_entity(%{properties: map}) :: struct
end

defprotocol Workrec.Repository.CloudDatastore.Entity.Decoder do
  def to_entity(value)
end

defimpl Workrec.Repository.CloudDatastore.Entity.Decoder, for: List do
  def to_entity(value) do
    Enum.map(value, &Workrec.Repository.CloudDatastore.Entity.Decoder.to_entity(&1))
  end
end
