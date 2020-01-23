defmodule Workrec.Model.TaskAction do
  @moduledoc """
  action of a task
  """

  @behaviour Workrec.Repository.CloudDatastore.EntityModel

  alias Workrec.Model.Event

  defstruct [
    :id,
    :user_id,
    :task_id,
    :time,
    :type,
    :deleted?,
    :created_at,
    :updated_at
  ]

  def kind_name, do: "TaskAction"

  def from_entity(properties) do
    %__MODULE__{
      id: properties["id"],
      user_id: properties["user_id"],
      task_id: properties["task_id"],
      time: properties["time"],
      type: String.to_existing_atom(properties["type"]),
      created_at: properties["created_at"],
      updated_at: properties["updated_at"]
    }
  end

  def apply_events(task, events) do
    Enum.reduce(events, task, &apply_event(&2, &1))
  end

  defp apply_event(action, %Event{action: :start_task} = event), do: do_apply_event(action, event, :start)
  defp apply_event(action, %Event{action: :pause_task} = event), do: do_apply_event(action, event, :pause)
  defp apply_event(action, %Event{action: :resume_task} = event), do: do_apply_event(action, event, :resume)
  defp apply_event(action, %Event{action: :finish_task} = event), do: do_apply_event(action, event, :finish)

  defp do_apply_event(_action, event, type) do
    %__MODULE__{
      id: event.task_action_id,
      user_id: event.user_id,
      task_id: event.task_id,
      time: event.time,
      type: type,
      created_at: event.created_at,
      updated_at: event.created_at
    }
  end
end

defimpl Workrec.Repository.CloudDatastore.Entity.Decoder, for: Workrec.Model.TaskAction do
  alias DsWrapper.Entity
  alias DsWrapper.Key
  alias Workrec.Model.TaskAction

  def to_entity(value) do
    Entity.new(Key.new(TaskAction.kind_name(), value.id), %{
      "id" => value.id,
      "user_id" => value.user_id,
      "task_id" => value.task_id,
      "time" => value.time,
      "type" => Atom.to_string(value.type),
      "created_at" => value.created_at,
      "updated_at" => value.updated_at
    })
  end
end

defmodule Workrec.Model.TaskActionList do
  @moduledoc """
  task action list
  """

  defstruct [:actions, :next_page_token]

  alias Workrec.Model.TaskAction

  def from_entity(results, cursor) do
    %__MODULE__{
      actions: Enum.map(results, fn %{entity: entity} -> TaskAction.from_entity(entity) end),
      next_page_token: cursor
    }
  end
end
