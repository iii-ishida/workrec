defmodule WorkrecWeb.TaskView do
  use WorkrecWeb, :view

  def render("index.json", %{tasks: tasks, next_page_token: next_page_token}) do
    %{
      tasks: render_many(tasks, WorkrecWeb.TaskView, "task.json"),
      next_page_token: next_page_token
    }
  end

  def render("task.json", %{task: task}) do
    task
  end
end
