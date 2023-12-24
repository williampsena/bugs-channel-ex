defmodule BugsChannel.Channels.Gnat.EventConsumer do
  @moduledoc """
  The module is in responsible for consuming events from NATs.
  """
  use BugsChannel.Channels.Gnat.Consumer
  alias BugsChannel.Events.Database.{MongoWriterProducer, RedisPushProducer}

  def dispatch_events(message, topic) do
    origin = String.to_existing_atom(message["x-origin"] || "home")

    case [database_mode(), event_target()] do
      ["mongo", _] -> sent_to_mongo(origin, message)
      [_, "redis"] -> sent_to_redis(origin, message)
      _ -> not_implemented_yet(topic)
    end
  end

  defp sent_to_mongo(origin, message) do
    MongoWriterProducer.enqueue(origin, message)

    Logger.debug("The message was delivered to mongo writer producer.")

    :ok
  end

  defp sent_to_redis(origin, message) do
    RedisPushProducer.enqueue(origin, message)

    Logger.debug("The message was delivered to redis producer.")

    :ok
  end

  defp not_implemented_yet(topic) do
    Logger.warning("Dead letter (#{topic}) not implemented yet.")
    :ok
  end

  defp database_mode(), do: Application.get_env(:bugs_channel, :database_mode)

  defp event_target(), do: Application.get_env(:bugs_channel, :event_target)
end
