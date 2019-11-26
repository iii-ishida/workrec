defmodule Utils.FirebaseAuth do
  @moduledoc """
  FirebaseAuth
  """

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

defmodule GoogleCerts do
  @moduledoc false

  @certs_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  def fetch do
    with {:ok, res} <- HTTPoison.get(@certs_url) do
      Jason.decode(res.body)
    end
  end
end
