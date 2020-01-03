defmodule WorkrecWeb.Router do
  use WorkrecWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :authenticate
  end

  scope "/" do
    pipe_through :api

    forward "/graph", Absinthe.Plug, schema: WorkrecWeb.Schema

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: WorkrecWeb.Schema
    end
  end

  defp authenticate(conn, _params) do
    project_id = System.get_env("GOOGLE_CLOUD_PROJECT")

    with ["Bearer " <> id_token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Utils.FirebaseAuth.verify_id_token(id_token, project_id) do
      Absinthe.Plug.put_options(conn, context: %{user_id: user_id})
    else
      _ ->
        conn
    end
  end
end
