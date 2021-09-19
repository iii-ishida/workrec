defmodule Workrec.MixProject do
  use Mix.Project

  def project do
    [
      app: :workrec,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Workrec.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:absinthe, "~> 1.6.5"},
      {:absinthe_plug, "~> 1.5.8"},
      {:cors_plug, "~> 2.0"},
      {:ds_wrapper, "~> 0.3.2"},
      {:elixir_uuid, "~> 1.2"},
      {:gettext, "~> 0.18"},
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.2"},
      {:jose, "~> 1.11"},
      {:phoenix, "~> 1.5.12"},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.5"},
      {:credo, "~> 1.5.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.25", only: :dev}
    ]
  end
end
