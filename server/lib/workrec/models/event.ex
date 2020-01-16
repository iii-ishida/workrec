defmodule Workrec.Event do
  @moduledoc """
  event
  """

  @behaviour Workrec.Repository.CloudDatastore.EntityModel

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

  def for_start_task(prev_event, params), do: for_change_task_state(prev_event, :start_task, params)
  def for_pause_task(prev_event, params), do: for_change_task_state(prev_event, :pause_task, params)
  def for_resume_task(prev_event, params), do: for_change_task_state(prev_event, :resume_task, params)
  def for_finish_task(prev_event, params), do: for_change_task_state(prev_event, :finish_task, params)
  def for_unfinish_task(prev_event, params), do: for_change_task_state(prev_event, :unfinish_task, params)

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
      action: String.to_existing_atom(properties["action"]),
      title: properties["title"],
      time: properties["time"],
      created_at: properties["created_at"]
    }
  end
end

defimpl Workrec.Repository.CloudDatastore.Entity.Decoder, for: Workrec.Event do
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
      "action" => Atom.to_string(value.action),
      "created_at" => value.created_at
    })
  end
end
