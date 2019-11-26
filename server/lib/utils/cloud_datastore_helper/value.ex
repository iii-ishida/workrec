defmodule Utils.DatastoreHelper.Value do
  @moduledoc """
  Helper for GoogleApi.Datastore.V1.Model.Value
  """

  alias GoogleApi.Datastore.V1.Model.{ArrayValue, Value}

  @doc """
  to GoogleApi.Datastore.V1.Model.Value

  ## Examples

      iex> Utils.DatastoreHelper.Value.from_native(123)
      %GoogleApi.Datastore.V1.Model.Value{integerValue: "123"}

      iex> Utils.DatastoreHelper.Value.from_native(123.4)
      %GoogleApi.Datastore.V1.Model.Value{doubleValue: 123.4}

      iex> Utils.DatastoreHelper.Value.from_native("some string")
      %GoogleApi.Datastore.V1.Model.Value{stringValue: "some string"}

      iex> Utils.DatastoreHelper.Value.from_native(true)
      %GoogleApi.Datastore.V1.Model.Value{booleanValue: true}

      iex> Utils.DatastoreHelper.Value.from_native(nil)
      %GoogleApi.Datastore.V1.Model.Value{nullValue: "NULL_VALUE"}

      iex> Utils.DatastoreHelper.Value.from_native(~U[2019-01-02 03:04:05.6Z])
      %GoogleApi.Datastore.V1.Model.Value{timestampValue: ~U[2019-01-02 03:04:05.6Z]}

      iex> Utils.DatastoreHelper.Value.from_native([123, "some string"])
      %GoogleApi.Datastore.V1.Model.Value{arrayValue: %GoogleApi.Datastore.V1.Model.ArrayValue{
        values: [
          %GoogleApi.Datastore.V1.Model.Value{integerValue: "123"},
          %GoogleApi.Datastore.V1.Model.Value{stringValue: "some string"}
        ]
      }}

  """
  def from_native(value) when is_integer(value) do
    %Value{integerValue: Integer.to_string(value)}
  end

  def from_native(value) when is_float(value) do
    %Value{doubleValue: value}
  end

  def from_native(value) when is_bitstring(value) do
    %Value{stringValue: value}
  end

  def from_native(value) when is_boolean(value) do
    %Value{booleanValue: value}
  end

  def from_native(value) when is_nil(value) do
    %Value{nullValue: "NULL_VALUE"}
  end

  def from_native(value) when is_list(value) do
    values = Enum.map(value, &from_native/1)
    %Value{arrayValue: %ArrayValue{values: values}}
  end

  def from_native(%DateTime{} = value) do
    %Value{timestampValue: value}
  end

  @doc """
  from GoogleApi.Datastore.V1.Model.Value

  ## Examples

    iex> Utils.DatastoreHelper.Value.to_native(%GoogleApi.Datastore.V1.Model.Value{integerValue: "123"})
    123

    iex> Utils.DatastoreHelper.Value.to_native(%GoogleApi.Datastore.V1.Model.Value{doubleValue: 123.4})
    123.4

    iex> Utils.DatastoreHelper.Value.to_native(%GoogleApi.Datastore.V1.Model.Value{stringValue: "some string"})
    "some string"

    iex> Utils.DatastoreHelper.Value.to_native(%GoogleApi.Datastore.V1.Model.Value{booleanValue: true})
    true

    iex> Utils.DatastoreHelper.Value.to_native(%GoogleApi.Datastore.V1.Model.Value{})
    nil

    iex> Utils.DatastoreHelper.Value.to_native(%GoogleApi.Datastore.V1.Model.Value{timestampValue: ~U[2019-01-02 03:04:05.6Z]})
    ~U[2019-01-02 03:04:05.6Z]

    iex> Utils.DatastoreHelper.Value.to_native(%GoogleApi.Datastore.V1.Model.Value{arrayValue: %GoogleApi.Datastore.V1.Model.ArrayValue{
    ...>   values: [
    ...>     %GoogleApi.Datastore.V1.Model.Value{integerValue: "123"},
    ...>     %GoogleApi.Datastore.V1.Model.Value{stringValue: "some string"}
    ...>   ]
    ...> }})
    [123, "some string"]
  """
  def to_native(%{integerValue: value}) when not is_nil(value) do
    value |> Integer.parse() |> elem(0)
  end

  def to_native(%{arrayValue: value}) when not is_nil(value) do
    Enum.map(value.values, &to_native/1)
  end

  def to_native(value) do
    not_nil_value = Map.from_struct(value) |> Enum.find(fn {_, v} -> v != nil end)

    case not_nil_value do
      {_, v} -> v
      _ -> nil
    end
  end
end
