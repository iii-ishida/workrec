defmodule Workrec.Model.Task do
  @moduledoc """
  task
  """

  @behaviour Workrec.Repository.CloudDatastore.EntityModel

  alias Workrec.Model.Event

  defstruct [
    :id,
    :user_id,
    :base_working_time,
    :paused_at,
    :started_at,
    :title,
    :state,
    :deleted?,
    :created_at,
    :updated_at
  ]

  def kind_name, do: "Task"

  def from_entity(properties) do
    %__MODULE__{
      id: properties["id"],
      user_id: properties["user_id"],
      base_working_time: properties["base_working_time"],
      paused_at: properties["paused_at"],
      started_at: properties["started_at"],
      title: properties["title"],
      state: String.to_existing_atom(properties["state"]),
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
      title: event.title,
      state: :unstarted,
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
        base_working_time: event.time,
        started_at: event.time,
        updated_at: event.created_at
    }
  end

  defp apply_event(task, %Event{action: :pause_task} = event) do
    %__MODULE__{
      task
      | state: :paused,
        paused_at: event.time,
        updated_at: event.created_at
    }
  end

  defp apply_event(task, %Event{action: :resume_task} = event) do
    %__MODULE__{
      task
      | state: :resumed,
        base_working_time: calculate_base_working_time(task, event.time),
        paused_at: nil,
        updated_at: event.created_at
    }
  end

  defp apply_event(task, %Event{action: :finish_task} = event) do
    %__MODULE__{
      task
      | state: :finished,
        paused_at: if(paused?(task), do: task.paused_at, else: event.time),
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

  defp paused?(task), do: task.state == :paused

  defp calculate_base_working_time(task, resumed_at) do
    DateTime.add(task.base_working_time, DateTime.diff(resumed_at, task.paused_at))
  end
end

defimpl Workrec.Repository.CloudDatastore.Entity.Decoder, for: Workrec.Model.Task do
  alias DsWrapper.Entity
  alias DsWrapper.Key
  alias Workrec.Model.Task

  def to_entity(value) do
    Entity.new(Key.new(Task.kind_name(), value.id), %{
      "id" => value.id,
      "user_id" => value.user_id,
      "title" => value.title,
      "base_working_time" => value.base_working_time,
      "started_at" => value.started_at,
      "paused_at" => value.paused_at,
      "state" => Atom.to_string(value.state),
      "created_at" => value.created_at,
      "updated_at" => value.updated_at
    })
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
