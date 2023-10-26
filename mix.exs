defmodule Niner.MixProject do
  use Mix.Project

  def project do
    [
      app: :niner,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Niner.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ecto_sql, "~> 3.8.2"},
      {:postgrex, "~> 0.16"},
      {:websockex, "~> 0.4.3"},
      {:poison, "~> 5.0.0"},
      {:httpoison, "~> 1.8"},
      {:aurum, "~> 0.2.0"},
      {:jason, "~> 1.4"},
      # {:bumblebee, "~> 0.2.0"},
      # {:axon, "~> 0.5.1"},
      {:axon, "~> 0.6.0"},
      # {:exla, "~> 0.5.2"},
      {:exla, "~> 0.6.0"},
      # {:nx, "~> 0.5.2"},
      {:nx, "~> 0.6.0"},
      # {:table_rex, "~> 3.1.1"},
      {:csv, "~> 3.0.5"},
      {:nimble_csv, "~> 1.1"}
      # {:scholar, "~> 0.1"}
      # {:explorer, "~> 0.5.6"}
      # {:explorer, "~> 0.6.1"}
    ]
  end
end
