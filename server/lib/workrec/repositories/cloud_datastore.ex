defmodule Workrec.Repositories.CloudDatastore do
  @moduledoc """
  Cloud Datastore repository
  """

  alias Utils.DatastoreHelper, as: Datastore
  alias Utils.DatastoreHelper.Entity
  alias Utils.DatastoreHelper.Transaction
  alias Workrec.Event
  alias Workrec.Repositories.CloudDatastore.Entity.Decoder
  alias Workrec.WorkList
  alias Workrec.WorkListItem

  defstruct [:store]

  @type commit_response :: GoogleApi.Datastore.V1.Model.CommitResponse.t() | nil
  @type t :: %__MODULE__{store: Datastore.t() | Transaction.t()}

  @spec new :: {:ok, t} | {:error, term}
  def new do
    with {:ok, store} <- Datastore.new() do
      {:ok, %__MODULE__{store: store}}
    end
  end

  @spec run_in_transaction(t, (t -> term)) :: {:ok, term} | {:error, term}
  def run_in_transaction(%{store: store}, fun) do
    Datastore.run_in_transaction(store, fn tx ->
      fun.(%__MODULE__{store: tx})
    end)
  end

  @spec run_in_transaction((t -> term)) :: {:ok, term} | {:error, term}
  def run_in_transaction(fun) do
    case new() do
      {:ok, repo} -> run_in_transaction(repo, fun)
      {:error, _} = error -> error
    end
  end

  @spec find(t, module, String.t()) :: {:ok, term} | {:error, term}
  def find(%{store: store}, module, id) do
    with {:ok, found} <- Datastore.find(store, Entity.new_key(module.kind_name(), id)) do
      case found do
        nil -> {:ok, nil}
        found -> {:ok, module.from_entity(found)}
      end
    end
  end

  @spec find!(t, module, String.t()) :: term | no_return
  def find!(store, module, id) do
    case find(store, module, id) do
      {:ok, found} -> found
      {:error, reason} -> raise reason
    end
  end

  @spec insert(t, list(struct) | struct) :: {:ok, commit_response} | {:error, term}
  def insert(%{store: store}, models) do
    entity = Decoder.to_entity(models)
    Datastore.insert(store, entity)
  end

  @spec insert!(t, list(struct) | struct) :: commit_response | no_return
  def insert!(repo, models) do
    case insert(repo, models) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  @spec upsert(t, list(struct) | struct) :: {:ok, commit_response} | {:error, term}
  def upsert(%{store: store}, models) do
    entity = Decoder.to_entity(models)
    Datastore.upsert(store, entity)
  end

  @spec upsert!(t, list(struct) | struct) :: commit_response | no_return
  def upsert!(repo, models) do
    case upsert(repo, models) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  @spec update(t, struct) :: {:ok, commit_response} | {:error, term}
  def update(%{store: store}, models) do
    entity = Decoder.to_entity(models)
    Datastore.update(store, entity)
  end

  @spec update!(t, list(struct) | struct) :: commit_response | no_return
  def update!(repo, models) do
    case update(repo, models) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  @spec delete(t, list(struct) | struct) :: {:ok, commit_response} | {:error, term}
  def delete(%{store: store}, models) when is_list(models) do
    keys = Enum.map(models, &Entity.new_key(&1.__struct__.kind_name, &1.id))
    Datastore.delete(store, keys)
  end

  def delete(%{store: store}, model) do
    delete(store, [model])
  end

  @spec delete!(t, list(struct) | struct) :: commit_response | no_return
  def delete!(repo, models) do
    case delete(repo, models) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  @spec list_events(t, String.t(), DateTime.t(), non_neg_integer(), String.t()) :: {:ok, list(Event.t())} | {:error, term}
  def list_events(%{store: store}, user_id, created_at, limit \\ 100, page_token \\ "") do
    import Utils.DatastoreHelper.Query

    query =
      new_query(Event.kind_name())
      |> where("user_id", "=", user_id)
      |> where("created_at", ">", created_at)
      |> order("user_id")
      |> order("created_at")
      |> limit(limit)
      |> start(page_token)

    with {:ok, result} <- Datastore.run_query(store, query) do
      {:ok, Enum.map(result.entities, &Event.from_entity/1)}
    end
  end

  def list_events!(repo, user_id, created_at, limit \\ 100, page_token \\ "") do
    case list_events(repo, user_id, created_at, limit, page_token) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  @spec find_last_event(t, String.t(), String.t()) :: {:ok, term} | {:error, term}
  def find_last_event(%{store: store}, user_id, work_id) do
    import Utils.DatastoreHelper.Query

    query =
      new_query(Event.kind_name())
      |> where("user_id", "=", user_id)
      |> where("work_id", "=", work_id)
      |> order("user_id")
      |> order("work_id")
      |> order("created_at", :desc)
      |> limit(1)

    case Datastore.run_query(store, query) do
      {:ok, %{entities: []}} -> {:ok, nil}
      {:ok, %{entities: [entity | _]}} -> {:ok, Event.from_entity(entity)}
      error -> error
    end
  end

  @spec find_last_event!(t, String.t(), String.t()) :: term | no_return
  def find_last_event!(repo, user_id, work_id) do
    case find_last_event(repo, user_id, work_id) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  @spec list_works(t, String.t(), non_neg_integer, String.t()) :: {:ok, WorkList.t()} | {:error, term}
  def list_works(%{store: store}, user_id, limit \\ 100, page_token \\ "") do
    import Utils.DatastoreHelper.Query

    query =
      new_query(WorkListItem.kind_name())
      |> where("user_id", "=", user_id)
      |> order("user_id")
      |> order("created_at", :desc)
      |> limit(limit)
      |> start(page_token)

    with {:ok, result} <- Datastore.run_query(store, query) do
      {:ok, WorkList.from_entity(result)}
    end
  end
end

defmodule Workrec.Repositories.CloudDatastore.EntityModel do
  @moduledoc """
  behaviour for Entity <-> Model
  """

  @callback kind_name() :: String.t()
  @callback from_entity(%{properties: map}) :: struct
end

defprotocol Workrec.Repositories.CloudDatastore.Entity.Decoder do
  def to_entity(value)
end

defimpl Workrec.Repositories.CloudDatastore.Entity.Decoder, for: List do
  def to_entity(value) do
    Enum.map(value, &Workrec.Repositories.CloudDatastore.Entity.Decoder.to_entity(&1))
  end
end
