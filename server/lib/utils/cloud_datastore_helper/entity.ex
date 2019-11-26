defmodule Utils.DatastoreHelper.Entity do
  @moduledoc """
  Helper for GoogleApi.Datastore.V1.Model.Entity
  """

  alias Utils.DatastoreHelper.Value
  alias GoogleApi.Datastore.V1.Model.{Entity, EntityResult, Key, PathElement}

  def new_key(parents \\ [], kind, name) do
    %Key{path: parents ++ [%PathElement{kind: kind, name: name}]}
  end

  def new(key, properties) do
    %Entity{
      key: key,
      properties:
        Enum.reduce(properties, %{}, fn {k, v}, acc ->
          Map.merge(acc, %{k => Value.from_native(v)})
        end)
    }
  end

  def to_map(%EntityResult{entity: entity}) do
    to_map(entity)
  end

  def to_map(%Entity{} = entity) do
    properties =
      Enum.reduce(entity.properties, %{}, fn {k, v}, acc ->
        Map.merge(acc, %{k => Value.to_native(v)})
      end)

    %{key: entity.key, properties: properties}
  end

  def to_map(nil) do
    nil
  end
end
