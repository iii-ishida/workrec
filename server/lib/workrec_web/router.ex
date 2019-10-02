defmodule WorkrecWeb.Router do
  use WorkrecWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1/works/", WorkrecWeb do
    pipe_through :api
    resources "/", WorkController, only: [:index, :create, :update, :delete] do
      post "/start", WorkController, :start, as: :start
      post "/pause", WorkController, :pause, as: :pause
      post "/resume", WorkController, :resume, as: :resume
      post "/finish", WorkController, :finish, as: :finish
      post "/unfinish", WorkController, :unfinish, as: :unfinish
    end
  end
end
