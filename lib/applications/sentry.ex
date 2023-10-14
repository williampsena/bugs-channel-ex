defmodule BugsChannel.Applications.Sentry do
  @moduledoc """
  This is the sentry application module in charge of startup http server.
  """

  require Logger

  @doc ~S"""
  Starts sentry http server supervisor

  ## Examples

      iex> BugsChannel.Applications.Sentry.start([])
      []

      iex> BugsChannel.Applications.Sentry.start([ enabled: true, port: 4001])
      [ {Bandit, [plug: BugsChannel.Plugins.Sentry.Router, port: 4001]} ]
  """
  def start(config \\ nil) do
    config = config || sentry_config()

    if config[:enabled],
      do: do_start(config),
      else: []
  end

  defp do_start(config) when is_list(config) do
    Logger.info("🐜 Starting Sentry Plugin Router...")

    [{Bandit, plug: BugsChannel.Plugins.Sentry.Router, port: config[:port]}]
  end

  defp sentry_config(), do: Application.get_env(:bugs_channel, :sentry)
end
