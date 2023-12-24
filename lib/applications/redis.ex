defmodule BugsChannel.Applications.Redis do
  @moduledoc """
  This is the redis application module in charge of startup redix processes.
  """

  require Logger

  @doc ~S"""
  Starts redix gen server

  ## Examples

      iex> BugsChannel.Applications.Redis.start("mongo", [foo: :bar])
      []

      iex> BugsChannel.Applications.Redis.start("redis", "wrong args")
      []

      iex> BugsChannel.Applications.Redis.start("redis", [ connection_url: "redis://localhost:6379/3" ])
      [{Redix, {"redis://localhost:6379/3", name: :redix}}]
  """
  def start(event_target, config \\ nil) do
    config = config || redis_config()
    do_start(event_target, config)
  end

  defp do_start("redis", config) when is_list(config) do
    Logger.info("⚙️  Starting Redis application...")

    [{Redix, {config[:connection_url], [name: :redix]}}]
  end

  defp do_start(_event_target, _config), do: []

  defp redis_config(), do: Application.get_env(:bugs_channel, :redis)
end
