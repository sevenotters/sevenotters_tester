defmodule SevenottersTester.MixProject do
  use Mix.Project

  def project do
    [
      app: :sevenotters_tester,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bcrypt_elixir, "~> 2.2"},
      {:seven, path: "../sevenotters"},
      {:sevenotters_postgres, path: "../sevenotters_postgres"},
      {:ve, "~> 0.1"}
    ]
  end

  defp aliases do
    [test: ["ecto.drop", "ecto.create", "ecto.migrate", "test"]]
  end
end
