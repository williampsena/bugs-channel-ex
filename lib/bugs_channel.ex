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
        {Bandit, plug: BugsChannel.Api.Router, port: server_port()}
      ] ++
        Applications.Settings.start(database_mode()) ++
        Applications.Sentry.start() ++
        Applications.Gnat.start() ++
        Applications.Channels.start() ++
        Applications.Mongo.start(database_mode()) ++
        Applications.Redis.start(event_target())

    opts = [strategy: :one_for_one, name: BugsChannel.Supervisor]

    Logger.info("🐛 Starting application...")

    Supervisor.start_link(children, opts)
  end

  @doc ~S"""
  Indicate that the database target is mongo.

  ## Examples

      iex> Application.put_env(:bugs_channel, :database_mode, "dbless")
      iex> BugsChannel.mongo_as_target?()
      false
  """
  def mongo_as_target?, do: database_mode() == "mongo"

  @doc ~S"""
  Indicate that the database target is redis.

  ## Examples
      iex> Application.put_env(:bugs_channel, :event_target, "redis")
      iex> BugsChannel.redis_as_target?()
      true
  """
  def redis_as_target?, do: event_target() == "redis"

  defp config(key), do: Application.get_env(:bugs_channel, key)
  defp server_port(), do: config(:server_port)
  defp database_mode(), do: config(:database_mode)
  defp event_target(), do: config(:event_target)
end
