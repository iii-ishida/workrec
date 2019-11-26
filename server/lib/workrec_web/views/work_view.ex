defmodule WorkrecWeb.WorkView do
  use WorkrecWeb, :view

  def render("index.json", %{works: works, next_page_token: next_page_token}) do
    %{
      works: render_many(works, WorkrecWeb.WorkView, "work.json"),
      next_page_token: next_page_token
    }
  end

  def render("work.json", %{work: work}) do
    work
  end
end
