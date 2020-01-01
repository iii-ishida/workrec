defmodule Workrec.TaskListItem do
  @moduledoc """
  item of work list
  """

  @behaviour Workrec.Repositories.CloudDatastore.EntityModel

  alias Workrec.Event

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

  @type state ::
          :unstarted
          | :started
          | :paused
          | :resumed
          | :finished

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          base_working_time: DateTime.t(),
          paused_at: DateTime.t(),
          started_at: DateTime.t(),
          title: String.t(),
          state: state,
          deleted?: boolean(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  def kind_name, do: "TaskListItem"

  def from_entity(properties) do
    state =
      case properties["state"] do
        1 -> :unstarted
        2 -> :started
        3 -> :paused
        4 -> :resumed
        5 -> :finished
        _ -> :unknown
      end

    %__MODULE__{
      id: properties["id"],
      user_id: properties["user_id"],
      base_working_time: properties["base_working_time"],
      paused_at: properties["paused_at"],
      started_at: properties["started_at"],
      title: properties["title"],
      state: state,
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

defimpl Workrec.Repositories.CloudDatastore.Entity.Decoder, for: Workrec.TaskListItem do
  alias DsWrapper.Entity
  alias DsWrapper.Key

  def to_entity(value) do
    state =
      case value.state do
        :unstarted -> 1
        :started -> 2
        :paused -> 3
        :resumed -> 4
        :finished -> 5
        _ -> 0
      end

    Entity.new(Key.new(Workrec.TaskListItem.kind_name(), value.id), %{
      "id" => value.id,
      "user_id" => value.user_id,
      "title" => value.title,
      "base_working_time" => value.base_working_time,
      "started_at" => value.started_at,
      "paused_at" => value.paused_at,
      "state" => state,
      "created_at" => value.created_at,
      "updated_at" => value.updated_at
    })
  end
end

defimpl Jason.Encoder, for: Workrec.TaskListItem do
  def encode(value, opts) do
    state =
      case value.state do
        :unstarted -> 1
        :started -> 2
        :paused -> 3
        :resumed -> 4
        :finished -> 5
        _ -> 0
      end

    map =
      Map.take(value, [
        :id,
        :title,
        :base_working_time,
        :started_at,
        :paused_at,
        :created_at,
        :updated_at
      ])
      |> Map.merge(%{state: state})

    Jason.Encode.map(map, opts)
  end
end

defmodule Workrec.TaskList do
  @moduledoc """
  task list
  """

  defstruct [:tasks, :next_page_token]

  @type t :: %__MODULE__{
          :tasks => list(Workrec.TaskListItem.t()),
          :next_page_token => String.t() | nil
        }

  def from_entity(result) do
    %__MODULE__{
      tasks: Enum.map(result.entities, &Workrec.TaskListItem.from_entity/1),
      next_page_token: result.cursor
    }
  end
end
