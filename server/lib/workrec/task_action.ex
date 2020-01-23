defmodule Workrec.TaskAction.List do
  @moduledoc """
  Workrec API: get task action list
  """

  alias Workrec.Repository.CloudDatastore, as: Repo
  alias Workrec.TaskActionEventStore

  def call(user_id, task_id, page_size \\ 100, page_token \\ "") do
    with {:ok, _} <- TaskActionEventStore.save_snapshots(user_id, task_id),
         {:ok, repo} <- Repo.new() do
      Repo.list_task_actions(repo, user_id, task_id, page_size, page_token)
    end
  end
end

defmodule Workrec.TaskActionEventStore do
  @moduledoc false

  alias Workrec.Model.{AggregationMeta, TaskAction}
  alias Workrec.Repository.CloudDatastore, as: Repo

  def save_snapshots(user_id, task_id) do
    Repo.run_in_transaction(fn tx ->
      aggregation_meta = find_aggregation_meta!(tx, user_id, task_id)
      events = Repo.list_events_for_task_actions!(tx, user_id, task_id, aggregation_meta.timestamp)
      do_save_snapshots!(tx, user_id, task_id, events)
    end)
  end

  defp do_save_snapshots!(_tx, _user_id, _task_id, events) when length(events) <= 0, do: {:ok, nil}

  defp do_save_snapshots!(tx, user_id, task_id, events) do
    task_action_list_items = apply_events!(tx, events)
    Repo.upsert!(tx, Enum.filter(task_action_list_items, &(!&1.deleted?)))
    Repo.delete!(tx, Enum.filter(task_action_list_items, & &1.deleted?))

    aggregation_meta = AggregationMeta.new(TaskAction.kind_name(), "#{user_id}-#{task_id}", List.last(events).created_at)
    Repo.upsert!(tx, aggregation_meta)
  end

  defp find_aggregation_meta!(tx, user_id, task_id) do
    aggregation_meta = AggregationMeta.new(TaskAction.kind_name(), "#{user_id}-#{task_id}")

    case Repo.find!(tx, AggregationMeta, aggregation_meta.id) do
      nil -> aggregation_meta
      found -> found
    end
  end

  defp apply_events!(tx, events) do
    events
    |> Enum.group_by(fn e -> e.task_action_id end)
    |> Enum.map(fn {task_action_id, grouped_events} ->
      task_action = Repo.find!(tx, TaskAction, task_action_id) || %TaskAction{}
      TaskAction.apply_events(task_action, grouped_events)
    end)
  end
end
