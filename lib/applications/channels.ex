defmodule BugsChannel.Applications.Channels do
  @moduledoc """
  This is the gnat application module in charge of startup processes.
  """

  require Logger

  @doc ~S"""
  Starts gnat gen server supervisor

  ## Examples

      iex> Application.put_env(:bugs_channel, :database_mode, "dbless")
      iex> Application.put_env(:bugs_channel, :event_target, "redis")
      iex> BugsChannel.Applications.Channels.start()
      [ {BugsChannel.Events.Producer, []}, {BugsChannel.Events.Database.RedisPushProducer, []} ]
  """
  def start() do
    Logger.info("⚙️  Starting GenStages...")

    event_producer() ++
      mongo_producer() ++
      redis_producer()
  end

  defp event_producer(),
    do: [{BugsChannel.Events.Producer, []}]

  defp mongo_producer() do
    if BugsChannel.mongo_as_target?(),
      do: [{BugsChannel.Events.Database.MongoWriterProducer, []}],
      else: []
  end

  defp redis_producer() do
    if BugsChannel.redis_as_target?(),
      do: [{BugsChannel.Events.Database.RedisPushProducer, []}],
      else: []
  end
end
