defmodule Workrec.Task.List do
  @moduledoc """
  Workrec API: get task list 
  """

  alias Workrec.Event
  alias Workrec.Repositories.CloudDatastore, as: Repo
  alias Workrec.SnapshotMeta
  alias Workrec.TaskListItem

  def call(user_id, page_size \\ 100, page_token \\ "") do
    with {:ok, repo} <- Repo.new(),
         {:ok, _} <- save_snapshots(repo, user_id) do
      Repo.list_tasks(repo, user_id, page_size, page_token)
    end
  end

  defp save_snapshots(repo, user_id) do
    Repo.run_in_transaction(repo, fn tx ->
      snapshot_meta = find_snapshot_meta!(tx, user_id)
      events = Repo.list_events!(tx, user_id, snapshot_meta.last_updated_at)
      do_save_snapshots!(tx, user_id, events)
    end)
  end

  defp do_save_snapshots!(_, _, events) when length(events) <= 0, do: {:ok, nil}

  defp do_save_snapshots!(tx, user_id, events) do
    task_list_items = apply_events!(tx, events)
    Repo.upsert!(tx, Enum.filter(task_list_items, &(!&1.deleted?)))
    Repo.delete!(tx, Enum.filter(task_list_items, & &1.deleted?))

    snapshot_meta = SnapshotMeta.new(user_id, TaskListItem.kind_name(), List.last(events))
    Repo.upsert!(tx, snapshot_meta)
  end

  defp find_snapshot_meta!(tx, user_id) do
    snapshot_id = SnapshotMeta.new_id(user_id, TaskListItem.kind_name())

    case Repo.find!(tx, SnapshotMeta, snapshot_id) do
      nil -> SnapshotMeta.new(user_id, TaskListItem.kind_name())
      snapshot -> snapshot
    end
  end

  defp apply_events!(tx, events) do
    events
    |> Enum.group_by(fn e -> e.task_id end)
    |> Enum.map(fn {task_id, grouped_events} ->
      task_list_item = Repo.find!(tx, Workrec.TaskListItem, task_id) || %TaskListItem{}
      Workrec.TaskListItem.apply_events(task_list_item, grouped_events)
    end)
  end
end

defmodule Workrec.Task.Create do
  @moduledoc """
  Workrec API: create a Task
  """

  alias Workrec.Event
  alias Workrec.Repositories.CloudDatastore, as: Repo

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
  alias Workrec.Repositories.CloudDatastore, as: Repo

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
  alias Workrec.Repositories.CloudDatastore, as: Repo

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

  alias Workrec.Repositories.CloudDatastore, as: Repo

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
