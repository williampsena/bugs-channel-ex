defmodule BugsChannel.MixProject do
  use Mix.Project

  def project do
    [
      app: :bugs_channel,
      version: "0.1.0",
      elixir: "~> 1.15-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.14"},
      {:bandit, "~> 0.6"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
