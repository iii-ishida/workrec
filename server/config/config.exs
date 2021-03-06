# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :workrec, WorkrecWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rgR55RtUAwlq7ILalgQG/zhzQvt/JTJQQWLXCRPaVb0cZQsaOqZi5iczEWYD0OjB",
  render_errors: [view: WorkrecWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: Workrec.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cors_plug,
  origin: [System.get_env("CLIENT_ORIGIN")],
  max_age: 600,
  headers: ["Content-Type", "Authorization"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
