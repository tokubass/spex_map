defmodule SpexMap.MixProject do
  use Mix.Project

  def project do
    [
      app: :spex_map,
      version: "0.1.0",
      elixir: "~> 1.6",
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
      {:yaml_elixir, "~> 2.1.0", only: :test},
      {:open_api_spex, "~> 2.0.0"}
    ]
  end
end
