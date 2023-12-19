defmodule BugsChannel.Channels.Gnat.EventConsumer do
  @moduledoc """
  The module is in responsible for consuming events from NATs.
  """
  use BugsChannel.Channels.Gnat.Consumer

  def dispatch_events(message, topic) do
    origin = String.to_existing_atom(message["x-origin"] || "home")
    database_mode = get_database_mode()

    if database_mode == "mongo",
      do: sent_to_mongo(origin, message),
      else: not_implemented_yet(topic)
  end

  def sent_to_mongo(origin, message) do
    BugsChannel.Events.Database.MongoWriterProducer.enqueue(origin, message)

    Logger.debug("The message was delivered to mongo writer producer.")

    :ok
  end

  defp not_implemented_yet(topic) do
    Logger.warning("Dead letter (#{topic}) not implemented yet.")
    :ok
  end

  defp get_database_mode(), do: Application.get_env(:bugs_channel, :database_mode)
end
