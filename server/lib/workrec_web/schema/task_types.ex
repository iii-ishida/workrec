defmodule WorkrecWeb.Schema.TaskTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  alias Workrec.TaskAction

  enum :state do
    value(:unstarted)
    value(:started)
    value(:paused)
    value(:resumed)
    value(:finished)
  end

  object :page_info do
    field(:end_cursor, :string)
    field(:has_next_page, non_null(:boolean))
  end

  object :task do
    field(:id, non_null(:id))
    field(:user_id, non_null(:id))
    field(:base_working_time, :datetime)
    field(:paused_at, :datetime)
    field(:started_at, :datetime)
    field(:title, non_null(:string))
    field(:state, non_null(:state))
    field(:created_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))

    field(:actions, non_null(:task_action_connection)) do
      arg(:first, non_null(:integer), default_value: 20)
      arg(:cursor, :string)

      resolve(fn task, args, %{context: context} ->
        with {:ok, task_action_list} <- TaskAction.List.call(context.user_id, task.id, args.first, Map.get(args, :cursor)) do
          {:ok,
           %{
             page_info: %{
               end_cursor: task_action_list.next_page_token,
               has_next_page: task_action_list.next_page_token != nil
             },
             edges: Enum.map(task_action_list.actions, fn action -> %{node: action} end)
           }}
        end
      end)
    end
  end

  object :task_connection do
    field(:page_info, :page_info)
    field(:edges, list_of(:task_edge))
  end

  object :task_edge do
    field(:node, non_null(:task))
  end

  object :task_action do
    field(:id, non_null(:id))
    field(:user_id, non_null(:id))
    field(:task_id, non_null(:id))
    field(:time, non_null(:datetime))
    field(:type, non_null(:string))
    field(:created_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))
  end

  object :task_action_edge do
    field(:node, non_null(:task_action))
  end

  object :task_action_connection do
    field(:page_info, :page_info)
    field(:edges, list_of(:task_action_edge))
  end
end
