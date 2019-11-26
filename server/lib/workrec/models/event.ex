defmodule Workrec.Event do
  @moduledoc """
  event
  """

  @behaviour Workrec.Repositories.CloudDatastore.EntityModel

  defstruct [
    :id,
    :prev_id,
    :user_id,
    :work_id,
    :action,
    :title,
    :time,
    :created_at
  ]

  @type action ::
          :create_work
          | :update_work
          | :delete_work
          | :start_work
          | :pause_work
          | :resume_work
          | :finish_work
          | :unfinish_work

  @type t :: %__MODULE__{
          id: String.t(),
          prev_id: String.t(),
          user_id: String.t(),
          work_id: String.t(),
          action: action,
          title: String.t(),
          time: DateTime.t(),
          created_at: DateTime.t()
        }

  def kind_name, do: "Event"

  def for_create_work(user_id, %{title: title}) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: new_id(),
      user_id: user_id,
      work_id: new_id(),
      action: :create_work,
      title: title,
      created_at: now
    }
  end

  def for_update_work(prev_event, %{title: title}) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: new_id(),
      prev_id: prev_event.id,
      user_id: prev_event.user_id,
      work_id: prev_event.work_id,
      action: :update_work,
      title: title,
      created_at: now
    }
  end

  def for_delete_work(prev_event) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: new_id(),
      prev_id: prev_event.id,
      user_id: prev_event.user_id,
      work_id: prev_event.work_id,
      action: :delete_work,
      created_at: now
    }
  end

  def for_start_work(prev_event, params),
    do: for_change_state_work(prev_event, :start_work, params)

  def for_pause_work(prev_event, params),
    do: for_change_state_work(prev_event, :pause_work, params)

  def for_resume_work(prev_event, params),
    do: for_change_state_work(prev_event, :resume_work, params)

  def for_finish_work(prev_event, params),
    do: for_change_state_work(prev_event, :finish_work, params)

  def for_unfinish_work(prev_event, params),
    do: for_change_state_work(prev_event, :unfinish_work, params)

  defp for_change_state_work(prev_event, action, %{time: time}) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: new_id(),
      prev_id: prev_event.id,
      user_id: prev_event.user_id,
      work_id: prev_event.work_id,
      action: action,
      time: time,
      created_at: now
    }
  end

  defp new_id, do: UUID.uuid4()

  def from_entity(%{properties: properties}) do
    %__MODULE__{
      id: properties["id"],
      user_id: properties["user_id"],
      work_id: properties["work_id"],
      action: int_to_action(properties["action"]),
      title: properties["title"],
      time: properties["time"],
      created_at: properties["created_at"]
    }
  end

  defp int_to_action(i) do
    case i do
      1 -> :create_work
      2 -> :update_work
      3 -> :delete_work
      4 -> :start_work
      5 -> :pause_work
      6 -> :resume_work
      7 -> :finish_work
      8 -> :unfinish_work
      _ -> :unknown
    end
  end
end

defimpl Workrec.Repositories.CloudDatastore.Entity.Decoder, for: Workrec.Event do
  alias Utils.DatastoreHelper.Entity

  def to_entity(value) do
    Entity.new(Entity.new_key(Workrec.Event.kind_name(), value.id), %{
      "id" => value.id,
      "prev_id" => value.prev_id,
      "user_id" => value.user_id,
      "work_id" => value.work_id,
      "title" => value.title,
      "time" => value.time,
      "action" => action_to_int(value.action),
      "created_at" => value.created_at
    })
  end

  defp action_to_int(action) do
    case action do
      :create_work -> 1
      :update_work -> 2
      :delete_work -> 3
      :start_work -> 4
      :pause_work -> 5
      :resume_work -> 6
      :finish_work -> 7
      :unfinish_work -> 8
      _ -> 0
    end
  end
end
