defmodule WorkrecWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias Workrec.Task

  import_types(Absinthe.Type.Custom)
  import_types(WorkrecWeb.Schema.TaskTypes)

  query do
    @desc "Get all tasks"
    field :list, :task_list do
      arg(:page_size, :integer)
      arg(:page_token, :string)

      resolve(fn _, %{context: %{user_id: user_id}} ->
        Task.List.call(user_id)
      end)
    end

    mutation do
      field :create_task, :id do
        arg(:title, non_null(:string))

        resolve(fn %{title: title}, %{context: %{user_id: user_id}} ->
          Task.Create.call(user_id: user_id, title: title)
        end)
      end

      field :update_task, :id do
        arg(:id, non_null(:id))
        arg(:title, non_null(:string))

        resolve(fn %{id: task_id, title: title}, %{context: %{user_id: user_id}} ->
          with {:ok, _} <- Task.Update.call(user_id: user_id, task_id: task_id, title: title) do
            {:ok, task_id}
          end
        end)
      end

      field :delete_task, :id do
        arg(:id, non_null(:id))

        resolve(fn %{id: task_id}, %{context: %{user_id: user_id}} ->
          with {:ok, _} <- Task.Delete.call(user_id: user_id, task_id: task_id) do
            {:ok, task_id}
          end
        end)
      end

      field :start_task, :id do
        arg(:id, non_null(:id))
        arg(:time, non_null(:datetime))

        resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
          with {:ok, _} <- Task.Start.call(user_id: user_id, task_id: task_id, time: time) do
            {:ok, task_id}
          end
        end)
      end

      field :pause_task, :id do
        arg(:id, non_null(:id))
        arg(:time, non_null(:datetime))

        resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
          with {:ok, _} <- Task.Pause.call(user_id: user_id, task_id: task_id, time: time) do
            {:ok, task_id}
          end
        end)
      end

      field :resume_task, :id do
        arg(:id, non_null(:id))
        arg(:time, non_null(:datetime))

        resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
          with {:ok, _} <- Task.Resume.call(user_id: user_id, task_id: task_id, time: time) do
            {:ok, task_id}
          end
        end)
      end

      field :finish_task, :id do
        arg(:id, non_null(:id))
        arg(:time, non_null(:datetime))

        resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
          with {:ok, _} <- Task.Finish.call(user_id: user_id, task_id: task_id, time: time) do
            {:ok, task_id}
          end
        end)
      end

      field :unfinish_task, :id do
        arg(:id, non_null(:id))
        arg(:time, non_null(:datetime))

        resolve(fn %{id: task_id, time: time}, %{context: %{user_id: user_id}} ->
          with {:ok, _} <- Task.Unfinish.call(user_id: user_id, task_id: task_id, time: time) do
            {:ok, task_id}
          end
        end)
      end
    end
  end

  def middleware(middleware, _field, %Absinthe.Type.Object{identifier: identifier})
      when identifier in [:query, :subscription, :mutation] do
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
