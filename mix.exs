defmodule SevenottersTester.MixProject do
  use Mix.Project

  def project do
    [
      app: :sevenotters_tester,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bcrypt_elixir, "~> 2.2"},
      {:seven, path: "../sevenotters"},
      {:sevenotters_mongo, path: "../sevenotters_mongo"},
      {:ve, "~> 0.1"}
    ]
  end
end
