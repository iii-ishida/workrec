defmodule Workrec.Work do
  alias Workrec.Event
  alias Workrec.WorkListItem
  alias Workrec.SnapshotMeta
  alias Workrec.Repositories.CloudDatastore, as: Repo

  def list(user_id, page_size \\ 100, page_token \\ "") do
    repo = Repo.new()

    with {:ok, _} <- create_snapshots(repo, user_id) do
      Repo.list_works(repo, user_id, page_size, page_token)
    end
  end

  defp create_snapshots(repo, user_id) do
    snapshot_id = SnapshotMeta.new_id(user_id, WorkListItem.kind_name())

    with {:ok, tx} <- Repo.transaction(repo),
         {:ok, snapshot} <- Repo.find(tx, SnapshotMeta, snapshot_id),
         snapshot = snapshot || SnapshotMeta.new(user_id, WorkListItem.kind_name()),
         {:ok, events} = Repo.list_events(tx, user_id, snapshot.last_updated_at) do

      if length(events) > 0 do
        mutations = apply_events_mutations(tx, events)
        snapshot = %SnapshotMeta{snapshot | last_updated_at: List.last(events).created_at}

        Repo.add_mutations(tx, mutations)
        |> Repo.add_mutations([Repo.upsert_mutation(snapshot)])
        |> Repo.commit()
      else
        {:ok, nil}
      end
    else
      {:error, reason} -> {:error, reason}
      reason -> {:error, reason}
      _ -> {:error, "UNKNOWN"}
    end
  end

  defp apply_events_mutations(tx, events) do
    grouped = Enum.group_by(events, fn e -> e.work_id end)

    works =
      Enum.map(grouped, fn {work_id, grouped_events} ->
        work = Repo.find!(tx, Workrec.WorkListItem, work_id) || %WorkListItem{}
        Workrec.WorkListItem.apply_events(work, grouped_events)
      end)

    Enum.map(works, &new_mutation/1)
  end

  defp new_mutation(%{id: id, deleted?: true}), do: Repo.delete_mutation(WorkListItem.kind_name(), id)
  defp new_mutation(work), do: Repo.upsert_mutation(work)

  def create(user_id: user_id, title: title) do
    repo = Repo.new()
    event = Event.for_create_work(user_id, %{title: title})
    with {:ok, _} <- Repo.insert(repo, event) do
      {:ok, event.work_id}
    end
  end

  def update(user_id: user_id, work_id: work_id, title: title) do
    with {:ok, tx} <- Repo.transaction(),
         {:ok, last_event} <- Repo.find_last_event(tx, user_id, work_id) do

      if last_event == nil do
        event = Event.for_update_work(last_event, %{title: title})
        with {:ok, _} <- Repo.insert(tx, event) do
          {:ok}
        end
      else
        {:error, :not_found}
      end
    end
  end

  def delete(user_id: user_id, work_id: work_id) do
    with {:ok, tx} <- Repo.transaction(),
         {:ok, last_event} <- Repo.find_last_event(tx, user_id, work_id) do

      if last_event do
        event = Event.for_delete_work(last_event)
        with {:ok, _} <- Repo.insert(tx, event) do
          {:ok}
        end
      else
        {:error, :not_found}
      end
    end
  end

  def start(user_id: user_id, work_id: work_id, time: time), do: change_state(user_id, work_id, time, &Event.for_start_work/2)
  def pause(user_id: user_id, work_id: work_id, time: time), do: change_state(user_id, work_id, time, &Event.for_pause_work/2)
  def resume(user_id: user_id, work_id: work_id, time: time), do: change_state(user_id, work_id, time, &Event.for_resume_work/2)
  def finish(user_id: user_id, work_id: work_id, time: time), do: change_state(user_id, work_id, time, &Event.for_finish_work/2)
  def unfinish(user_id: user_id, work_id: work_id, time: time), do: change_state(user_id, work_id, time, &Event.for_unfinish_work/2)

  defp change_state(user_id, work_id, time, event_factory) do
    with {:ok, time, 0} <- DateTime.from_iso8601(time) do
      do_change_state(user_id, work_id, time, event_factory)
    else
      _ -> {:error, :bad_request}
    end
  end

  defp do_change_state(user_id, work_id, time, event_factory) do
    with {:ok, tx} <- Repo.transaction(),
         {:ok, last_event} <- Repo.find_last_event(tx, user_id, work_id) do

      if last_event do
        event = event_factory.(last_event, %{time: time})
        with {:ok, _} <- Repo.insert(tx, event) do
          {:ok}
        end
      else
        {:error, :not_found}
      end
    end
  end
end
