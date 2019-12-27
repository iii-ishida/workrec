defmodule Workrec.SnapshotMeta do
  @moduledoc """
  meta data of snapshot
  """

  @behaviour Workrec.Repositories.CloudDatastore.EntityModel

  defstruct [:id, :user_id, :kind, :last_updated_at]

  def new(user_id, kind, last_event \\ %Workrec.Event{}) do
    %__MODULE__{
      id: new_id(user_id, kind),
      user_id: user_id,
      kind: kind,
      last_updated_at: last_event.created_at
    }
  end

  def new_id(user_id, kind), do: "#{user_id}-#{kind}"

  def kind_name, do: "SnapshotMeta"

  def from_entity(properties) do
    %__MODULE__{
      id: properties["id"],
      user_id: properties["user_id"],
      kind: properties["kind"],
      last_updated_at: properties["last_updated_at"]
    }
  end
end

defimpl Workrec.Repositories.CloudDatastore.Entity.Decoder, for: Workrec.SnapshotMeta do
  alias DsWrapper.Entity
  alias DsWrapper.Key

  def to_entity(value) do
    Entity.new(Key.new(Workrec.SnapshotMeta.kind_name(), value.id), %{
      "id" => value.id,
      "kind" => value.kind,
      "user_id" => value.user_id,
      "last_updated_at" => value.last_updated_at
    })
  end
end
