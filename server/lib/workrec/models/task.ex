defmodule Workrec.Model.Task do
  @moduledoc """
  task
  """

  @behaviour Workrec.Repository.CloudDatastore.EntityModel

  alias DsWrapper.Entity
  alias Workrec.Model.Event

  defstruct [
    :id,
    :user_id,
    :state,
    :title,
    :current_work,
    :working_time,
    :started_at,
    :deleted?,
    :created_at,
    :updated_at
  ]

  def kind_name, do: "Task"

  def from_entity(properties) do
    current_work = if properties["current_work"] != nil, do: %{start_time: Map.get(properties["current_work"], "start_time"), end_time: Map.get(properties["current_work"], "end_time")}

    %__MODULE__{
      id: properties["id"],
      user_id: properties["user_id"],
      state: String.to_existing_atom(properties["state"]),
      title: properties["title"],
      current_work: current_work,
      working_time: properties["working_time"],
      started_at: properties["started_at"],
      created_at: properties["created_at"],
      updated_at: properties["updated_at"]
    }
  end

  def apply_events(task, events) do
    Enum.reduce(events, task, &apply_event(&2, &1))
  end

  defp apply_event(_task, %Event{action: :create_task} = event) do
    %__MODULE__{
      id: event.task_id,
      user_id: event.user_id,
      state: :unstarted,
      title: event.title,
      working_time: 0,
      created_at: event.created_at,
      updated_at: event.created_at
    }
  end

  defp apply_event(task, %Event{action: :update_task} = event) do
    %__MODULE__{task | title: event.title, updated_at: event.created_at}
  end

  defp apply_event(task, %Event{action: :delete_task}) do
    %__MODULE__{task | deleted?: true}
  end

  defp apply_event(task, %Event{action: :start_task} = event) do
    %__MODULE__{
      task
      | state: :started,
        current_work: %{start_time: event.time},
        started_at: event.time,
        updated_at: event.created_at
    }
  end

  defp apply_event(task, %Event{action: :pause_task} = event) do
    %__MODULE__{
      task
      | state: :paused,
        current_work: %{start_time: task.current_work.start_time, end_time: event.time},
        updated_at: event.created_at
    }
  end

  defp apply_event(task, %Event{action: :resume_task} = event) do
    %__MODULE__{
      task
      | state: :resumed,
        current_work: %{start_time: event.time},
        working_time: calculate_working_time(task),
        updated_at: event.created_at
    }
  end

  defp apply_event(task, %Event{action: :finish_task} = event) do
    %__MODULE__{
      task
      | state: :finished,
        current_work: %{start_time: task.current_work.start_time, end_time: task.current_work.end_time || event.time},
        updated_at: event.created_at
    }
  end

  defp apply_event(task, %Event{action: :unfinish_task} = event) do
    %__MODULE__{
      task
      | state: :paused,
        updated_at: event.created_at
    }
  end

  defp calculate_working_time(%{working_time: working_time, current_work: %{start_time: start_time, end_time: end_time}}) do
    working_time + DateTime.diff(end_time, start_time) * 1000
  end
end

defimpl Workrec.Repository.CloudDatastore.Entity.Decoder, for: Workrec.Model.Task do
  alias DsWrapper.Entity
  alias DsWrapper.Key
  alias Workrec.Model.Task

  def to_entity(value) do
    m = %{
      "id" => value.id,
      "user_id" => value.user_id,
      "title" => value.title,
      "state" => Atom.to_string(value.state),
      "working_time" => value.working_time,
      "started_at" => value.started_at,
      "created_at" => value.created_at,
      "updated_at" => value.updated_at
    }

    w =
      if value.current_work == nil do
        %{}
      else
        %{"current_work" => Entity.new(nil, %{"start_time" => Map.get(value.current_work, :start_time), "end_time" => Map.get(value.current_work, :end_time)})}
      end

    Entity.new(Key.new(Task.kind_name(), value.id), Map.merge(m, w))
  end
end

defmodule Workrec.Model.TaskList do
  @moduledoc """
  task list
  """

  defstruct [:tasks, :next_page_token]

  alias Workrec.Model.Task

  def from_entity(results, cursor) do
    %__MODULE__{
      tasks: Enum.map(results, fn %{entity: entity} -> Task.from_entity(entity) end),
      next_page_token: cursor
    }
  end
end
