defmodule BugsChannel do
  @moduledoc """
  This is the application module in charge of starting processes.
  """
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Bandit, plug: BugsChannel.Plugs.HealthCheck}
    ]

    opts = [strategy: :one_for_one, name: BugsChannel.Supervisor]

    Logger.info("🐛 Starting application...")

    Supervisor.start_link(children, opts)
  end
end
