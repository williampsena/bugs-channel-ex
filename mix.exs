defmodule BugsChannel.MixProject do
  use Mix.Project

  def project do
    [
      app: :bugs_channel,
      version: "0.1.0",
      elixir: "~> 1.15-rc",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        test: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      releases: [
        bugs_channel: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    run_application(Mix.env())
  end

  def run_application(:test), do: extra_applications()

  def run_application(_), do: [mod: {BugsChannel, []}] ++ extra_applications()

  def extra_applications do
    [
      extra_applications: [:logger, :hammer]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.14"},
      {:bandit, "~> 0.6"},
      {:gen_stage, "~> 1.2"},
      {:gnat, "~> 1.6"},
      {:yaml_elixir, "~> 2.9"},
      {:ecto, "~> 3.10"},
      {:hammer, "~> 6.1"},

      # development deps
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.28", only: :dev},

      # testing deps
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.17.1", only: :test},
      {:mock, "~> 0.3.0", only: :test},
      {:hammox, "~> 0.7", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [api: ["run --no-halt "]]
  end
end
