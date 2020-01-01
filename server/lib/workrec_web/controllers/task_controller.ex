defmodule WorkrecWeb.TaskController do
  use WorkrecWeb, :controller

  alias Workrec.Task

  action_fallback WorkrecWeb.FallbackController

  plug :authenticate

  def index(conn, _params) do
    user_id = conn.assigns[:user_id]

    with {:ok, task_list} <- Task.List.call(user_id) do
      render(conn, "index.json", task_list)
    end
  end

  def create(conn, %{"title" => title}) do
    user_id = conn.assigns[:user_id]

    with {:ok, task_id} <- Task.Create.call(user_id: user_id, title: title) do
      conn
      |> put_resp_header("location", task_id)
      |> send_resp(:created, "")
    end
  end

  def update(conn, %{"id" => task_id, "title" => title}) do
    user_id = conn.assigns[:user_id]

    with {:ok, _} <- Task.Update.call(user_id: user_id, task_id: task_id, title: title) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def delete(conn, %{"id" => task_id}) do
    user_id = conn.assigns[:user_id]

    with {:ok, _} <- Task.Delete.call(user_id: user_id, task_id: task_id) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def start(conn, %{"task_id" => task_id, "time" => time}) do
    user_id = conn.assigns[:user_id]

    with {:ok, _} <- Task.Start.call(user_id: user_id, task_id: task_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def pause(conn, %{"task_id" => task_id, "time" => time}) do
    user_id = conn.assigns[:user_id]

    with {:ok, _} <- Task.Pause.call(user_id: user_id, task_id: task_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def resume(conn, %{"task_id" => task_id, "time" => time}) do
    user_id = conn.assigns[:user_id]

    with {:ok, _} <- Task.Resume.call(user_id: user_id, task_id: task_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def finish(conn, %{"task_id" => task_id, "time" => time}) do
    user_id = conn.assigns[:user_id]

    with {:ok, _} <- Task.Finish.call(user_id: user_id, task_id: task_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  def unfinish(conn, %{"task_id" => task_id, "time" => time}) do
    user_id = conn.assigns[:user_id]

    with {:ok, _} <- Task.Unfinish.call(user_id: user_id, task_id: task_id, time: time) do
      conn
      |> send_resp(:ok, "")
    end
  end

  defp authenticate(conn, _params) do
    project_id = System.get_env("GOOGLE_CLOUD_PROJECT")

    with [_, id_token] <- get_req_header(conn, "authorization") |> List.first() |> String.split(" "),
         {:ok, user_id} <- Utils.FirebaseAuth.verify_id_token(id_token, project_id) do
      assign(conn, :user_id, user_id)
    else
      _ ->
        conn |> send_resp(:unauthorized, "") |> halt()
    end
  end
end
