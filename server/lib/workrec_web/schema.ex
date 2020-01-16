defmodule WorkrecWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias Workrec.Task

  import_types(Absinthe.Type.Custom)
  import_types(WorkrecWeb.Schema.TaskTypes)

  query do
    @desc "Get all tasks"
    field :tasks, non_null(:task_connection) do
      arg(:first, non_null(:integer), default_value: 20)
      arg(:cursor, :string)

      resolve(fn args, %{context: context} ->
        with {:ok, task_list} <- Task.List.call(context.user_id, args.first, Map.get(args, :cursor)) do
          {:ok,
           %{
             page_info: %{
               end_cursor: task_list.next_page_token,
               has_next_page: task_list.next_page_token != nil
             },
             edges: Enum.map(task_list.tasks, fn task -> %{node: task} end)
           }}
        end
      end)
    end

    @desc "Get a task"
    field :task, :task do
      arg(:id, non_null(:id))

      resolve(fn %{id: id}, %{context: context} ->
        Task.Get.call(context.user_id, id)
      end)
    end
  end

  mutation do
    field :create_task, :task do
      arg(:title, non_null(:string))

      resolve(fn %{title: title}, %{context: %{user_id: user_id}} ->
        with {:ok, task_id} <- Task.Create.call(user_id: user_id, title: title) do
          Task.Get.call(user_id, task_id)
        end
      end)
    end

    field :update_task, :task do
      arg(:id, non_null(:id))
      arg(:title, non_null(:string))

      resolve(fn %{id: task_id, title: title}, %{context: %{user_id: user_id}} ->
        with {:ok, _} <- Task.Update.call(user_id: user_id, task_id: task_id, title: title) do
          Task.Get.call(user_id, task_id)
        end
      end)
    end

    field :delete_task, :boolean do
      arg(:id, non_null(:id))

      resolve(fn %{id: task_id}, %{context: %{user_id: user_id}} ->
        with {:ok, _} <- Task.Delete.call(user_id: user_id, task_id: task_id) do
          {:ok, true}
        end
      end)
    end

    field :start_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
        with {:ok, _} <- Task.Start.call(user_id: user_id, task_id: task_id, time: time) do
          Task.Get.call(user_id, task_id)
        end
      end)
    end

    field :pause_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
        with {:ok, _} <- Task.Pause.call(user_id: user_id, task_id: task_id, time: time) do
          Task.Get.call(user_id, task_id)
        end
      end)
    end

    field :resume_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
        with {:ok, _} <- Task.Resume.call(user_id: user_id, task_id: task_id, time: time) do
          Task.Get.call(user_id, task_id)
        end
      end)
    end

    field :finish_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
        with {:ok, _} <- Task.Finish.call(user_id: user_id, task_id: task_id, time: time) do
          Task.Get.call(user_id, task_id)
        end
      end)
    end

    field :unfinish_task, :task do
      arg(:id, non_null(:id))
      arg(:time, non_null(:datetime))

      resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
        with {:ok, _} <- Task.Unfinish.call(user_id: user_id, task_id: task_id, time: time) do
          Task.Get.call(user_id, task_id)
        end
      end)
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
