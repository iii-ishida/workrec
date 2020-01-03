defmodule WorkrecWeb.Schema.TaskTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  enum :state do
    value(:unstarted)
    value(:started)
    value(:paused)
    value(:resumed)
    value(:finished)
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
  end

  object :task_list do
    field(:tasks, non_null(list_of(:task)))
    field(:next_page_token, :string)
  end
end
