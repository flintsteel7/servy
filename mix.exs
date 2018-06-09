defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      description: "A humble HTTP server",
      version: "0.1.0",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Servy, []},
      env: [port: 3333]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.12.0"},
      {:earmark, "~> 1.2"}
    ]
  end
end
