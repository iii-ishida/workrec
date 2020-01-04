defmodule Utils.FirebaseAuth do
  @moduledoc """
  FirebaseAuth
  """

  alias Utils.FirebaseAuth.GoogleCerts

  @doc """
  Verify id_token.

  (https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library)

  ## Examples

      iex> verify_id_token(id_token, "gcp-project-id")
      {:ok, "user-id"}

  """
  @spec verify_id_token(String.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def verify_id_token(id_token, project_id) do
    with %{fields: %{"kid" => kid}} <- JOSE.JWT.peek_protected(id_token),
         {:ok, cert} <- fetch_cert(kid),
         jwk = JOSE.JWK.from_pem(cert),
         {true, payload, _} <- JOSE.JWS.verify_strict(jwk, ["RS256"], id_token),
         {:ok, payload} <- Jason.decode(payload),
         true <- verify_clams(payload, project_id) do
      {:ok, payload["sub"]}
    else
      {:error, reason} -> {:error, reason}
      reason -> {:error, reason}
      _ -> {:error, "UNKNOWN"}
    end
  end

  defp fetch_cert(kid) do
    with {:ok, certs} <- GoogleCerts.fetch() do
      case Map.fetch(certs, kid) do
        :error -> {:error, "#{kid} is not found"}
        result -> result
      end
    end
  end

  defp verify_clams(payload, project_id) do
    now = DateTime.utc_now() |> DateTime.to_unix(:second)

    payload["exp"] > now &&
      payload["iat"] <= now &&
      payload["aud"] == project_id &&
      payload["iss"] == "https://securetoken.google.com/#{project_id}" &&
      payload["sub"] != "" &&
      payload["auth_time"] <= now
  end
end

defmodule Utils.FirebaseAuth.GoogleCerts do
  @moduledoc false

  @certs_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  def fetch do
    case get_cache() do
      {:ok, _} = cache -> cache
      _ -> do_fetch()
    end
  end

  defp do_fetch do
    with {:ok, res} <- HTTPoison.get(@certs_url),
         {:ok, certs} <- Jason.decode(res.body) do
      expire_at = calc_expire_at(res.headers)
      save_cache(%{certs: certs, expire_at: expire_at})

      {:ok, certs}
    end
  end

  defp get_cache do
    if :erlang.whereis(__MODULE__) != :undefined do
      Agent.get(__MODULE__, & &1) |> do_get_cache()
    end
  end

  defp do_get_cache(%{certs: certs, expire_at: expire_at}) do
    if expire_at > DateTime.utc_now(), do: {:ok, certs}
  end

  defp do_get_cache(_), do: nil

  defp save_cache(certs) do
    if :erlang.whereis(__MODULE__) == :undefined do
      Agent.start_link(fn -> [] end, name: __MODULE__)
    end

    Agent.update(__MODULE__, fn _ -> certs end)
  end

  defp calc_expire_at(headers) do
    header_map = headers |> Enum.into(%{})

    with %{"max_age" => max_age} <- Regex.named_captures(~r/max-age=(?<max_age>[0-9]+)/, header_map["Cache-Control"] || "") do
      max_age = String.to_integer(max_age)
      DateTime.utc_now() |> DateTime.add(max_age)
    end
  end
end
