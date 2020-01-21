defmodule Workrec.Model.AggregationMeta do
  @moduledoc false

  @behaviour Workrec.Repository.CloudDatastore.EntityModel

  defstruct [:id, :aggregation_name, :aggregation_id, :timestamp]

  def new(aggregation_name, id, timestamp \\ nil) do
    %__MODULE__{
      id: "#{aggregation_name}-#{id}",
      aggregation_name: aggregation_name,
      aggregation_id: id,
      timestamp: timestamp
    }
  end

  def kind_name, do: "AggregationMeta"

  def from_entity(properties) do
    %__MODULE__{
      id: properties["id"],
      aggregation_name: properties["aggregation_name"],
      aggregation_id: properties["aggregation_id"],
      timestamp: properties["timestamp"]
    }
  end
end

defimpl Workrec.Repository.CloudDatastore.Entity.Decoder, for: Workrec.Model.AggregationMeta do
  alias DsWrapper.Entity
  alias DsWrapper.Key
  alias Workrec.Model.AggregationMeta

  def to_entity(value) do
    Entity.new(Key.new(AggregationMeta.kind_name(), value.id), %{
      "id" => value.id,
      "aggregation_name" => value.aggregation_name,
      "aggregation_id" => value.aggregation_id,
      "timestamp" => value.timestamp
    })
  end
end
