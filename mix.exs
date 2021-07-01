defmodule Minecraft.MixProject do
  use Mix.Project

  @description "A Minecraft server implementation in Elixir."
  @project_url "https://github.com/thecodeboss/minecraft"

  def project do
    [
      app: :minecraft,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:nifs],
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # URLs
      source_url: @project_url,
      homepage_url: @project_url,

      # Hex
      description: @description,
      package: package(),

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
      {:httpoison, "~> 1.2"},
      {:inch_ex, only: :docs},
      {:mock, "~> 0.3.0", only: :test},
      {:ranch, "~> 2.0"},
      {:poison, "~> 4.0"}
    ]
  end

  defp package do
    [
      maintainers: ["Michael Oliver"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url},
      files: ~w(README.md LICENSE mix.exs lib)
    ]
  end
end
