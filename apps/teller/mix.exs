defmodule Teller.MixProject do
  use Mix.Project

  def project do
    [
      app: :teller,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :absinthe_plug],
      mod: {Teller.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.4.0"},
      {:plug, "~> 1.5.1"},
      {:absinthe_plug, "~> 1.4.0"},
      {:database, in_umbrella: true}
    ]
  end
end
