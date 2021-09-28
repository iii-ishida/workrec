defmodule WorkrecWeb.Schema.TaskTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  alias WorkrecWeb.Resolvers

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

  object :work_record do
    field(:start_time, :datetime)
    field(:end_time, :datetime)
  end

  object :task do
    field(:id, non_null(:id))
    field(:current_work, :work_record)
    field(:working_time, non_null(:integer))
    field(:started_at, :datetime)
    field(:title, non_null(:string))
    field(:state, non_null(:state))
    field(:created_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))

    field(:actions, non_null(:task_action_connection)) do
      arg(:first, non_null(:integer), default_value: 20)
      arg(:cursor, :string)

      resolve(&Resolvers.Task.list_task_actions/3)
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
