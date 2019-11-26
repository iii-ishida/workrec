defmodule Utils.DatastoreHelper.Query do
  @moduledoc """
  Helper for GoogleApi.Datastore.V1.Model.Query
  """

  alias Utils.DatastoreHelper.Value

  alias GoogleApi.Datastore.V1.Model.{
    CompositeFilter,
    Filter,
    KindExpression,
    PropertyFilter,
    PropertyOrder,
    PropertyReference,
    Query
  }

  @doc """
  return new %GoogleApi.Datastore.V1.Model.Query

  ## Examples

      iex> Utils.DatastoreHelper.Query.new_query("some_kind")
      %GoogleApi.Datastore.V1.Model.Query{
        kind: %GoogleApi.Datastore.V1.Model.KindExpression{name: "some_kind"}
      }

  """
  def new_query(kind) do
    %Query{kind: %KindExpression{name: kind}}
  end

  @doc """
  return new %GoogleApi.Datastore.V1.Model.Query

  ## Examples

      iex> import Utils.DatastoreHelper.Query
      iex> new_query("some_kind")
      ...> |> where("some_property", "=", "some value")
      %GoogleApi.Datastore.V1.Model.Query{
        kind: %GoogleApi.Datastore.V1.Model.KindExpression{name: "some_kind"},
        filter: %GoogleApi.Datastore.V1.Model.Filter{
          compositeFilter: %GoogleApi.Datastore.V1.Model.CompositeFilter{
            filters: [
              %GoogleApi.Datastore.V1.Model.Filter{
                propertyFilter: %GoogleApi.Datastore.V1.Model.PropertyFilter{
                  property: %GoogleApi.Datastore.V1.Model.PropertyReference{name: "some_property"},
                  op: "EQUAL",
                  value: %GoogleApi.Datastore.V1.Model.Value{stringValue: "some value"}
                }
              }
            ],
            op: "AND"
          }
        }
      }

  """
  def where(query, property, op, value) do
    composite_filter =
      case query.filter do
        %{compositeFilter: composite_filter} -> composite_filter
        _ -> %CompositeFilter{filters: [], op: "AND"}
      end

    filter = %Filter{
      propertyFilter: %PropertyFilter{
        property: to_property_reference(property),
        op: to_op(op),
        value: Value.from_native(value)
      }
    }

    filters = composite_filter.filters ++ [filter]
    composite_filter = %CompositeFilter{composite_filter | filters: filters}

    %Query{query | filter: %Filter{compositeFilter: composite_filter}}
  end

  def order(query, property, direction \\ nil) do
    order = [new_order(property, to_direction(direction))]

    %Query{query | order: (query.order || []) ++ order}
  end

  def limit(query, limit) do
    %Query{query | limit: limit}
  end

  def start(query, cursor) do
    %Query{query | startCursor: cursor}
  end

  defp new_order(property, direction) do
    %PropertyOrder{
      property: to_property_reference(property),
      direction: direction
    }
  end

  defp to_property_reference(property) do
    %PropertyReference{name: property}
  end

  defp to_op("="), do: "EQUAL"
  defp to_op("<"), do: "LESS_THAN"
  defp to_op("<="), do: "LESS_THAN_OR_EQUAL"
  defp to_op(">"), do: "GREATER_THAN"
  defp to_op(">="), do: "GREATER_THAN_OR_EQUAL"

  defp to_direction(:desc), do: "DESCENDING"
  defp to_direction(_), do: "ASCENDING"
end
