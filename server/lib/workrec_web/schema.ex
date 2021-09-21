defmodule WorkrecWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias WorkrecWeb.Resolvers

  import_types(Absinthe.Type.Custom)
  import_types(WorkrecWeb.Schema.TaskTypes)

  query do
    @desc "Get all tasks"
    field :tasks, non_null(:task_connection) do
      arg(:first, non_null(:integer), default_value: 20)
      arg(:cursor, :string)

      resolve(&Resolvers.Task.list_tasks/3)
    end

    @desc "Get a task"
    field :task, :task do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Task.find_task/3)
    end
  end

  mutation do
    field :create_task, :task do
      arg(:title, non_null(:string))

      resolve(&Resolvers.Task.create_task/3)
    end

    field :update_task, :task do
      arg(:id, non_null(:id))
      arg(:title, non_null(:string))

      resolve(&Resolvers.Task.update_task/3)
    end

    field :delete_task, :boolean do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Task.delete_task/3)
    end

    field :start_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(&Resolvers.Task.start_task/3)
    end

    field :pause_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(&Resolvers.Task.pause_task/3)
    end

    field :resume_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(&Resolvers.Task.resume_task/3)
    end

    field :finish_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(&Resolvers.Task.finish_task/3)
    end

    field :unfinish_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(&Resolvers.Task.unfinish_task/3)
    end
  end

  def middleware(middleware, _field, %Absinthe.Type.Object{identifier: identifier}) when identifier in [:query, :subscription, :mutation] do
    [WorkrecWeb.Middlewares.Authentication | middleware]
  end

  def middleware(middleware, _field, _object), do: middleware
end

defmodule WorkrecWeb.Middlewares.Authentication do
  @moduledoc false

  @behaviour Absinthe.Middleware

  def call(resolution, _) do
    case resolution.context do
      %{user_id: _} ->
        resolution

      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "unauthenticated"})
    end
  end
end
