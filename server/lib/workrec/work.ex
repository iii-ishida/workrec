defmodule Workrec.Work.List do
  @moduledoc """
  Workrec API: list 
  """

  alias Workrec.Event
  alias Workrec.Repositories.CloudDatastore, as: Repo
  alias Workrec.SnapshotMeta
  alias Workrec.WorkListItem

  def call(user_id, page_size \\ 100, page_token \\ "") do
    with {:ok, repo} <- Repo.new(),
         {:ok, _} <- save_snapshots(repo, user_id) do
      Repo.list_works(repo, user_id, page_size, page_token)
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
    work_list_items = apply_events!(tx, events)
    Repo.upsert!(tx, Enum.filter(work_list_items, &(!&1.deleted?)))
    Repo.delete!(tx, Enum.filter(work_list_items, & &1.deleted?))

    snapshot_meta = SnapshotMeta.new(user_id, WorkListItem.kind_name(), List.last(events))
    Repo.upsert!(tx, snapshot_meta)
  end

  defp find_snapshot_meta!(tx, user_id) do
    snapshot_id = SnapshotMeta.new_id(user_id, WorkListItem.kind_name())

    case Repo.find!(tx, SnapshotMeta, snapshot_id) do
      nil -> SnapshotMeta.new(user_id, WorkListItem.kind_name())
      snapshot -> snapshot
    end
  end

  defp apply_events!(tx, events) do
    events
    |> Enum.group_by(fn e -> e.work_id end)
    |> Enum.map(fn {work_id, grouped_events} ->
      work_list_item = Repo.find!(tx, Workrec.WorkListItem, work_id) || %WorkListItem{}
      Workrec.WorkListItem.apply_events(work_list_item, grouped_events)
    end)
  end
end

defmodule Workrec.Work.Create do
  @moduledoc """
  Workrec API: create 
  """

  alias Workrec.Event
  alias Workrec.Repositories.CloudDatastore, as: Repo

  def call(user_id: user_id, title: title) do
    event = Event.for_create_work(user_id, %{title: title})

    with {:ok, repo} <- Repo.new(),
         {:ok, _} <- Repo.insert(repo, event) do
      {:ok, event.work_id}
    end
  end
end

defmodule Workrec.Work.Update do
  @moduledoc """
  Workrec API: update 
  """

  alias Workrec.Event
  alias Workrec.Repositories.CloudDatastore, as: Repo

  def call(user_id: user_id, work_id: work_id, title: title) do
    Repo.run_in_transaction(fn tx ->
      case Repo.find_last_event!(tx, user_id, work_id) do
        nil ->
          {:error, :not_found}

        last_event ->
          event = Event.for_update_work(last_event, %{title: title})
          Repo.insert!(tx, event)
      end
    end)
  end
end

defmodule Workrec.Work.Delete do
  @moduledoc """
  Workrec API: delete 
  """

  alias Workrec.Event
  alias Workrec.Repositories.CloudDatastore, as: Repo

  def call(user_id: user_id, work_id: work_id) do
    Repo.run_in_transaction(fn tx ->
      case Repo.find_last_event!(tx, user_id, work_id) do
        nil ->
          {:error, :not_found}

        last_event ->
          event = Event.for_delete_work(last_event)
          Repo.insert!(tx, event)
      end
    end)
  end
end

defmodule Workrec.Work.ChangeStateWork do
  @moduledoc false

  alias Workrec.Repositories.CloudDatastore, as: Repo

  def change_state(user_id, work_id, time, event_factory) do
    case DateTime.from_iso8601(time) do
      {:ok, time, 0} -> do_change_state(user_id, work_id, time, event_factory)
      _ -> {:error, :bad_request}
    end
  end

  defp do_change_state(user_id, work_id, time, event_factory) do
    Repo.run_in_transaction(fn tx ->
      case Repo.find_last_event!(tx, user_id, work_id) do
        nil ->
          {:error, :not_found}

        last_event ->
          event = event_factory.(last_event, %{time: time})
          Repo.insert!(tx, event)
      end
    end)
  end
end

defmodule Workrec.Work.Start do
  @moduledoc """
  Workrec API: start work
  """

  import Workrec.Work.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, work_id: work_id, time: time) do
    change_state(user_id, work_id, time, &Event.for_start_work/2)
  end
end

defmodule Workrec.Work.Pause do
  @moduledoc """
  Workrec API: pause work 
  """

  import Workrec.Work.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, work_id: work_id, time: time) do
    change_state(user_id, work_id, time, &Event.for_pause_work/2)
  end
end

defmodule Workrec.Work.Resume do
  @moduledoc """
  Workrec API: resume work
  """

  import Workrec.Work.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, work_id: work_id, time: time) do
    change_state(user_id, work_id, time, &Event.for_resume_work/2)
  end
end

defmodule Workrec.Work.Finish do
  @moduledoc """
  Workrec API: finish work
  """

  import Workrec.Work.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, work_id: work_id, time: time) do
    change_state(user_id, work_id, time, &Event.for_finish_work/2)
  end
end

defmodule Workrec.Work.Unfinish do
  @moduledoc """
  Workrec API: unfinish work
  """

  import Workrec.Work.ChangeStateWork
  alias Workrec.Event

  def call(user_id: user_id, work_id: work_id, time: time) do
    change_state(user_id, work_id, time, &Event.for_unfinish_work/2)
  end
end
