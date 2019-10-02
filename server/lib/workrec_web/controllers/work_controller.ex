defmodule WorkrecWeb.WorkController do
  use WorkrecWeb, :controller

  alias Workrec.Work

  action_fallback WorkrecWeb.FallbackController

  plug :authenticate

  def index(conn, _params) do
    user_id = conn.assigns[:user_id]
    with {:ok, worklist} <- Work.list(user_id) do
      render(conn, "index.json", worklist)
    end
  end

  def create(conn, %{"title" => title}) do
    user_id = conn.assigns[:user_id]
    with {:ok, work_id} <- Work.create(user_id: user_id, title: title) do
      conn
      |> put_resp_header("location", work_id)
      |> send_resp(:created, "")
    end
  end

  def update(conn, %{"id" => work_id, "title" => title}) do
    user_id = conn.assigns[:user_id]
    with {:ok} <- Work.update(user_id: user_id, work_id: work_id, title: title) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def delete(conn, %{"id" => work_id}) do
    user_id = conn.assigns[:user_id]
    with {:ok} <- Work.delete(user_id: user_id, work_id: work_id) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def start(conn, %{"work_id" => work_id, "time" => time}) do
    user_id = conn.assigns[:user_id]
    with {:ok} <- Work.start(user_id: user_id, work_id: work_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def pause(conn, %{"work_id" => work_id, "time" => time}) do
    user_id = conn.assigns[:user_id]
    with {:ok} <- Work.pause(user_id: user_id, work_id: work_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def resume(conn, %{"work_id" => work_id, "time" => time}) do
    user_id = conn.assigns[:user_id]
    with {:ok} <- Work.resume(user_id: user_id, work_id: work_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def finish(conn, %{"work_id" => work_id, "time" => time}) do
    user_id = conn.assigns[:user_id]
    with {:ok} <- Work.finish(user_id: user_id, work_id: work_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def unfinish(conn, %{"work_id" => work_id, "time" => time}) do
    user_id = conn.assigns[:user_id]
    with {:ok} <- Work.unfinish(user_id: user_id, work_id: work_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  defp authenticate(conn, _params) do
    project_id = System.get_env("GOOGLE_CLOUD_PROJECT")

    with [_, id_token] <- get_req_header(conn, "authorization") |> List.first |> String.split(" "),
         {:ok, user_id} <- FirebaseAuth.verify_id_token(id_token, project_id) do
      assign(conn, :user_id, user_id)
    else
      _ ->
        conn |> send_resp(:unauthorized, "") |> halt()
    end
  end
end
