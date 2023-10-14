defmodule BugsChannel do
  @moduledoc """
  This is the application module in charge of starting processes.
  """
  use Application
  use Supervisor

  alias BugsChannel.Applications

  require Logger

  def init(args) do
    args
  end

  def start(_type, _args) do
    children =
      [
        {BugsChannel.Cache, []},
        {Bandit, plug: BugsChannel.Router, port: server_port()}
      ] ++
        Applications.Settings.start(database_mode()) ++
        Applications.Sentry.start() ++
        Applications.Gnat.start() ++
        Applications.Channels.start()

    opts = [strategy: :one_for_one, name: BugsChannel.Supervisor]

    Logger.info("🐛 Starting application...")

    Supervisor.start_link(children, opts)
  end

  defp config(key), do: Application.get_env(:bugs_channel, key)
  defp server_port(), do: config(:server_port)
  defp database_mode(), do: config(:database_mode)
end
