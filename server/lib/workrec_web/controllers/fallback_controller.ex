defmodule WorkrecWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use WorkrecWeb, :controller
  require Logger

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> render(WorkrecWeb.ErrorView, :"400")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(WorkrecWeb.ErrorView, :"404")
  end

  def call(conn, {:error, reson}) do
    Logger.error("ERROR: #{inspect(reson)}, #{inspect(Process.info(self(), :current_stacktrace))}")

    conn
    |> put_status(:internal_server_error)
    |> render(WorkrecWeb.ErrorView, :"500")
  end

  def call(conn, reson) do
    Logger.error("ERROR: #{inspect(reson)}")

    conn
    |> put_status(:internal_server_error)
    |> render(WorkrecWeb.ErrorView, :"500")
  end
end
