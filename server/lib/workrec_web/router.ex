defmodule WorkrecWeb.Router do
  use WorkrecWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WorkrecWeb do
    pipe_through :api
  end
end
