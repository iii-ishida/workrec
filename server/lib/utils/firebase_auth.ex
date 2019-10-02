defmodule FirebaseAuth do
  def verify_id_token(id_token, project_id) do
    # https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library

    %{fields: %{"kid" => kid}} = JOSE.JWT.peek_protected(id_token)

    with {:ok, cert} <- fetch_cert(kid),
         jwk <- JOSE.JWK.from_pem(cert),
         {true, payload, _} <- JOSE.JWS.verify_strict(jwk, ["RS256"], id_token),
         {:ok, payload} <- Jason.decode(payload),
         true <- verify_clams(payload, project_id) do
      {:ok, payload["sub"]}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error}
    end
  end

  defp fetch_cert(kid) do
    with {:ok, certs} <- GoogleCerts.fetch do
      Map.fetch(certs, kid)
    else
      _ ->
        {:error}
    end
  end

  defp verify_clams(payload, project_id) do
    now = DateTime.utc_now |> DateTime.to_unix(:second)

    payload["exp"] > now &&
    payload["iat"] <= now &&
    payload["aud"] == project_id &&
    payload["iss"] == "https://securetoken.google.com/" <> project_id &&
    payload["sub"] != "" &&
    payload["auth_time"] <= now
  end
end

defmodule GoogleCerts do
  @certs_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  def fetch do
    with {:ok, certs} <- CertStore.get do
      {:ok, certs}
    else
      _ ->
        fetch_certs
    end
  end


  defp fetch_certs do
    with {:ok, res} <- HTTPoison.get(@certs_url),
         {:ok, certs} <- Jason.decode(res.body) do
      {:ok, certs}
    else
      _ ->
        {:error}
    end
  end
end

defmodule CertStore do
#   use GenServer
  def get do
    {:error}
  end

# 
#   def start_link do
#     GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
#   end
# 
#   def init(state) do
#     {:ok, state}
#   end
# 
#   def handle_call(:get, _from, state) do
#     state
#     |> get_certs
#     |> reply
#   end
# 
#   def handle_cast({:save, certs, expires}, _state) do
#     {:noreply, {certs, expired_at}}
#   end
# 
#   defp get_certs({certs, expired_at}) do
#     if expired_at >= DateTime.utc_now do
#       {:ok, certs}
#     else
#       {:error}
#     end
#   end
end
