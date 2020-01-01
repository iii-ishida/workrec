defmodule WorkrecWeb.Router do
  use WorkrecWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1/tasks/", WorkrecWeb do
    pipe_through :api

    resources "/", TaskController, only: [:index, :create, :update, :delete] do
      post "/start", TaskController, :start, as: :start
      post "/pause", TaskController, :pause, as: :pause
      post "/resume", TaskController, :resume, as: :resume
      post "/finish", TaskController, :finish, as: :finish
      post "/unfinish", TaskController, :unfinish, as: :unfinish
    end
  end
end
