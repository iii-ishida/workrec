defmodule WorkrecWeb.Resolvers.Task do
  @moduledoc false

  alias Workrec.Task
  alias Workrec.TaskAction

  def list_tasks(_parent, args, %{context: context}) do
    with {:ok, task_list} <- Task.List.call(context.user_id, args.first, Map.get(args, :cursor)) do
      {:ok,
       %{
         page_info: %{
           end_cursor: task_list.next_page_token,
           has_next_page: task_list.next_page_token != nil
         },
         edges: Enum.map(task_list.tasks, &%{node: &1})
       }}
    end
  end

  def find_task(_parent, %{id: id}, %{context: context}) do
    Task.Get.call(context.user_id, id)
  end

  def create_task(_parent, %{title: title}, %{context: %{user_id: user_id}}) do
    with {:ok, task_id} <- Task.Create.call(user_id: user_id, title: title) do
      Task.Get.call(user_id, task_id)
    end
  end

  def update_task(_parent, %{id: task_id, title: title}, %{context: %{user_id: user_id}}) do
    with {:ok, _} <- Task.Update.call(user_id: user_id, task_id: task_id, title: title) do
      Task.Get.call(user_id, task_id)
    end
  end

  def delete_task(_parent, %{id: task_id}, %{context: %{user_id: user_id}}) do
    with {:ok, _} <- Task.Delete.call(user_id: user_id, task_id: task_id) do
      {:ok, true}
    end
  end

  def start_task(_parent, %{id: task_id, time: time}, %{context: %{user_id: user_id}}) do
    with {:ok, _} <- Task.Start.call(user_id: user_id, task_id: task_id, time: time) do
      Task.Get.call(user_id, task_id)
    end
  end

  def pause_task(_parent, %{id: task_id, time: time}, %{context: %{user_id: user_id}}) do
    with {:ok, _} <- Task.Pause.call(user_id: user_id, task_id: task_id, time: time) do
      Task.Get.call(user_id, task_id)
    end
  end

  def resume_task(_parent, %{id: task_id, time: time}, %{context: %{user_id: user_id}}) do
    with {:ok, _} <- Task.Resume.call(user_id: user_id, task_id: task_id, time: time) do
      Task.Get.call(user_id, task_id)
    end
  end

  def finish_task(_parent, %{id: task_id, time: time}, %{context: %{user_id: user_id}}) do
    with {:ok, _} <- Task.Finish.call(user_id: user_id, task_id: task_id, time: time) do
      Task.Get.call(user_id, task_id)
    end
  end

  def unfinish_task(_parent, %{id: task_id, time: time}, %{context: %{user_id: user_id}}) do
    with {:ok, _} <- Task.Unfinish.call(user_id: user_id, task_id: task_id, time: time) do
      Task.Get.call(user_id, task_id)
    end
  end

  def list_task_actions(task, args, %{context: context}) do
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
  end
end
