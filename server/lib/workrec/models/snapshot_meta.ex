defmodule Workrec.SnapshotMeta do
  defstruct [:id, :user_id, :kind, :last_updated_at]

  def new(user_id, kind) do
    {:ok, zeroTime} = DateTime.from_unix(0)

    %__MODULE__{
      id: new_id(user_id, kind),
      user_id: user_id,
      kind: kind,
      last_updated_at: zeroTime
    }
  end

  def new_id(user_id, kind), do: "#{user_id}-#{kind}"

  def kind_name, do: "SnapshotMeta"

  def from_entity(%{properties: properties}) do
    %__MODULE__{
      id: properties["id"],
      user_id: properties["user_id"],
      kind: properties["kind"],
      last_updated_at: properties["last_updated_at"],
    }
  end
end

defimpl Utils.Datastore.Entity.Decoder, for: Workrec.SnapshotMeta do
  alias Utils.Datastore

  def to_entity(value) do
    Datastore.new_entity(Datastore.new_key(Workrec.SnapshotMeta.kind_name(), value.id), %{
      "id" => value.id,
      "kind" => value.kind,
      "user_id" => value.user_id,
      "last_updated_at" => value.last_updated_at
    })
  end
end
