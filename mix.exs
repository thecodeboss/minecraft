defmodule Minecraft.MixProject do
  use Mix.Project

  @project_url "https://github.com/thecodeboss/minecraft"

  def project do
    [
      app: :minecraft,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # URLs
      source_url: @project_url,
      homepage_url: @project_url,

      # Docs
      name: "Minecraft",
      docs: [
        # The main page in the docs
        main: "readme",
        extras: ["README.md": [title: "Minecraft"]]
      ],

      # Coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Minecraft.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:inch_ex, only: :docs},
      {:ranch, "~> 1.5"},
      {:poison, "~> 3.1"}
    ]
  end
end
