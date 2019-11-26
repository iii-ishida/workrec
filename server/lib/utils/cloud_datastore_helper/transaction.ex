defmodule Utils.DatastoreHelper.Transaction do
  @moduledoc """
  Helper for Transaction
  """

  use Agent

  defstruct [:connection, :id, :pid]

  @type t :: %__MODULE__{
          connection: Tesla.Client.t(),
          id: String.t(),
          pid: pid
        }

  @spec new(Tesla.Client.t(), String.t()) :: {:ok, t} | {:error, term}
  def new(connection, id) do
    case Agent.start_link(fn -> [] end) do
      {:ok, pid} -> {:ok, %__MODULE__{connection: connection, id: id, pid: pid}}
      error -> error
    end
  end

  @spec new!(Tesla.Client.t(), String.t()) :: t | no_return
  def new!(connection, id) do
    case new(connection, id) do
      {:ok, tx} -> tx
      {:error, reason} -> raise reason
    end
  end

  def insert(tx, mutations), do: add_mutations(tx, mutations)

  def upsert(tx, mutations), do: add_mutations(tx, mutations)

  def update(tx, mutations), do: add_mutations(tx, mutations)

  def delete(tx, mutations), do: add_mutations(tx, mutations)

  defp add_mutations(%{pid: pid}, mutations) do
    Agent.update(pid, &(&1 ++ mutations))
  end

  def mutations(%{pid: pid}) do
    Agent.get(pid, & &1)
  end

  def stop(%{pid: pid}) do
    Agent.stop(pid)
  end
end
