defmodule Workrec.Event do
  @moduledoc """
  event
  """

  @behaviour Workrec.Repositories.CloudDatastore.EntityModel

  defstruct [
    :id,
    :prev_id,
    :user_id,
    :task_id,
    :action,
    :title,
    :time,
    :created_at
  ]

  @type action ::
          :create_task
          | :update_task
          | :delete_task
          | :start_task
          | :pause_task
          | :resume_task
          | :finish_task
          | :unfinish_task

  @type t :: %__MODULE__{
          id: String.t(),
          prev_id: String.t(),
          user_id: String.t(),
          task_id: String.t(),
          action: action,
          title: String.t(),
          time: DateTime.t(),
          created_at: DateTime.t()
        }

  def kind_name, do: "Event"

  def for_create_task(user_id, %{title: title}) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: new_id(),
      user_id: user_id,
      task_id: new_id(),
      action: :create_task,
      title: title,
      created_at: now
    }
  end

  def for_update_task(prev_event, %{title: title}) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: new_id(),
      prev_id: prev_event.id,
      user_id: prev_event.user_id,
      task_id: prev_event.task_id,
      action: :update_task,
      title: title,
      created_at: now
    }
  end

  def for_delete_task(prev_event) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: new_id(),
      prev_id: prev_event.id,
      user_id: prev_event.user_id,
      task_id: prev_event.task_id,
      action: :delete_task,
      created_at: now
    }
  end

  def for_start_task(prev_event, params),
    do: for_change_task_state(prev_event, :start_task, params)

  def for_pause_task(prev_event, params),
    do: for_change_task_state(prev_event, :pause_task, params)

  def for_resume_task(prev_event, params),
    do: for_change_task_state(prev_event, :resume_task, params)

  def for_finish_task(prev_event, params),
    do: for_change_task_state(prev_event, :finish_task, params)

  def for_unfinish_task(prev_event, params),
    do: for_change_task_state(prev_event, :unfinish_task, params)

  defp for_change_task_state(prev_event, action, %{time: time}) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: new_id(),
      prev_id: prev_event.id,
      user_id: prev_event.user_id,
      task_id: prev_event.task_id,
      action: action,
      time: time,
      created_at: now
    }
  end

  defp new_id, do: UUID.uuid4()

  def from_entity(properties) do
    %__MODULE__{
      id: properties["id"],
      user_id: properties["user_id"],
      task_id: properties["task_id"],
      action: int_to_action(properties["action"]),
      title: properties["title"],
      time: properties["time"],
      created_at: properties["created_at"]
    }
  end

  defp int_to_action(i) do
    case i do
      1 -> :create_task
      2 -> :update_task
      3 -> :delete_task
      4 -> :start_task
      5 -> :pause_task
      6 -> :resume_task
      7 -> :finish_task
      8 -> :unfinish_task
      _ -> :unknown
    end
  end
end

defimpl Workrec.Repositories.CloudDatastore.Entity.Decoder, for: Workrec.Event do
  alias DsWrapper.Entity
  alias DsWrapper.Key

  def to_entity(value) do
    Entity.new(Key.new(Workrec.Event.kind_name(), value.id), %{
      "id" => value.id,
      "prev_id" => value.prev_id,
      "user_id" => value.user_id,
      "task_id" => value.task_id,
      "title" => value.title,
      "time" => value.time,
      "action" => action_to_int(value.action),
      "created_at" => value.created_at
    })
  end

  defp action_to_int(action) do
    case action do
      :create_task -> 1
      :update_task -> 2
      :delete_task -> 3
      :start_task -> 4
      :pause_task -> 5
      :resume_task -> 6
      :finish_task -> 7
      :unfinish_task -> 8
      _ -> 0
    end
  end
end
