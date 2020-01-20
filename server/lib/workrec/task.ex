defmodule Workrec.Task.List do
  @moduledoc """
  Workrec API: get task list 
  """

  alias Workrec.Repository.CloudDatastore, as: Repo
  alias Workrec.TaskEventStore

  def call(user_id, page_size \\ 100, page_token \\ "") do
    with {:ok, _} <- TaskEventStore.save_snapshots(user_id),
         {:ok, repo} <- Repo.new() do
      Repo.list_tasks(repo, user_id, page_size, page_token)
    end
  end
end

defmodule Workrec.Task.Get do
  @moduledoc """
  Workrec API: get a task
  """

  alias Workrec.Repository.CloudDatastore, as: Repo
  alias Workrec.Task
  alias Workrec.TaskEventStore

  def call(user_id, task_id) do
    with {:ok, _} <- TaskEventStore.save_snapshot(user_id, task_id),
         {:ok, repo} <- Repo.new() do
      Repo.find(repo, Task, task_id)
    end
  end
end

defmodule Workrec.Task.Create do
  @moduledoc """
  Workrec API: create a Task
  """

  alias Workrec.Event
  alias Workrec.Repository.CloudDatastore, as: Repo

  def call(user_id: user_id, title: title) do
    event = Event.for_create_task(user_id, %{title: title})

    with {:ok, repo} <- Repo.new(),
         {:ok, _} <- Repo.insert(repo, event) do
      {:ok, event.task_id}
    end
  end
end

defmodule Workrec.Task.Update do
  @moduledoc """
  Workrec API: update a task
  """

  alias Workrec.Event
  alias Workrec.Repository.CloudDatastore, as: Repo

  def call(user_id: user_id, task_id: task_id, title: title) do
    Repo.run_in_transaction(fn tx ->
      case Repo.find_last_event!(tx, user_id, task_id) do
        nil ->
          {:error, :not_found}

        last_event ->
          event = Event.for_update_task(last_event, %{title: title})
          Repo.insert!(tx, event)
      end
    end)
  end
end

defmodule Workrec.Task.Delete do
  @moduledoc """
  Workrec API: delete a task
  """

  alias Workrec.Event
  alias Workrec.Repository.CloudDatastore, as: Repo

  def call(user_id: user_id, task_id: task_id) do
    Repo.run_in_transaction(fn tx ->
      case Repo.find_last_event!(tx, user_id, task_id) do
        nil ->
          {:error, :not_found}

        last_event ->
          event = Event.for_delete_task(last_event)
          Repo.insert!(tx, event)
      end
    end)
  end
end

defmodule Workrec.Task.ChangeStateWork do
  @moduledoc false

  alias Workrec.Repository.CloudDatastore, as: Repo

  def change_state(user_id, task_id, time, event_factory) do
    Repo.run_in_transaction(fn tx ->
      case Repo.find_last_event!(tx, user_id, task_id) do
        nil ->
          {:error, :not_found}

        last_event ->
          event = event_factory.(last_event, %{time: time})
          Repo.insert!(tx, event)
      end
    end)
  end
end

defmodule Workrec.Task.Start do
  @moduledoc """
  Workrec API: start a task
  """

  import Workrec.Task.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, task_id: task_id, time: time) do
    change_state(user_id, task_id, time, &Event.for_start_task/2)
  end
end

defmodule Workrec.Task.Pause do
  @moduledoc """
  Workrec API: pause a task
  """

  import Workrec.Task.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, task_id: task_id, time: time) do
    change_state(user_id, task_id, time, &Event.for_pause_task/2)
  end
end

defmodule Workrec.Task.Resume do
  @moduledoc """
  Workrec API: resume a task
  """

  import Workrec.Task.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, task_id: task_id, time: time) do
    change_state(user_id, task_id, time, &Event.for_resume_task/2)
  end
end

defmodule Workrec.Task.Finish do
  @moduledoc """
  Workrec API: finish a task
  """

  import Workrec.Task.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, task_id: task_id, time: time) do
    change_state(user_id, task_id, time, &Event.for_finish_task/2)
  end
end

defmodule Workrec.Task.Unfinish do
  @moduledoc """
  Workrec API: unfinish a task
  """

  import Workrec.Task.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, task_id: task_id, time: time) do
    change_state(user_id, task_id, time, &Event.for_unfinish_task/2)
  end
end

defmodule Workrec.TaskEventStore do
  @moduledoc false

  alias Workrec.Repository.CloudDatastore, as: Repo
  alias Workrec.Task
  alias Workrec.AggregationMeta

  def save_snapshots(user_id) do
    Repo.run_in_transaction(fn tx ->
      aggregation_meta = find_aggregation_meta!(tx, user_id)
      events = Repo.list_events!(tx, user_id, aggregation_meta.timestamp)
      do_save_snapshots!(tx, user_id, events)
    end)
  end

  def save_snapshot(user_id, task_id) do
    Repo.run_in_transaction(fn tx ->
      last_updated_at = (Repo.find!(tx, Task, task_id) || %Task{}).updated_at

      events = Repo.list_events_for_task!(tx, user_id, task_id, last_updated_at)
      do_save_snapshots!(tx, user_id, events)
    end)
  end

  defp do_save_snapshots!(_, _, events) when length(events) <= 0, do: {:ok, nil}

  defp do_save_snapshots!(tx, user_id, events) do
    task_list_items = apply_events!(tx, events)
    Repo.upsert!(tx, Enum.filter(task_list_items, &(!&1.deleted?)))
    Repo.delete!(tx, Enum.filter(task_list_items, & &1.deleted?))

    aggregation_meta = AggregationMeta.new(Task.kind_name(), user_id, List.last(events).created_at)
    Repo.upsert!(tx, aggregation_meta)
  end

  defp find_aggregation_meta!(tx, user_id) do
    aggregation_meta = AggregationMeta.new(Task.kind_name(), user_id)

    case Repo.find!(tx, AggregationMeta, aggregation_meta.id) do
      nil -> aggregation_meta
      found -> found
    end
  end

  defp apply_events!(tx, events) do
    events
    |> Enum.group_by(fn e -> e.task_id end)
    |> Enum.map(fn {task_id, grouped_events} ->
      task_list_item = Repo.find!(tx, Task, task_id) || %Task{}
      Task.apply_events(task_list_item, grouped_events)
    end)
  end
end
