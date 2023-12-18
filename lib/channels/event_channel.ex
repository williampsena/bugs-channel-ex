defmodule BugsChannel.Channels.EventChannel do
  @moduledoc """
  The module is in charge of support helpers for event channel.
  """
  require Logger

  alias BugsChannel.Channels.Context, as: ChannelsContext

  @doc ~S"""
  Publish message to a topic
  """
  def publish(topic, message) when is_binary(topic) and is_binary(message) do
    try do
      ChannelsContext.event_channel().publish(topic, message)
    rescue
      e ->
        Logger.error("❌ An error occurred while attempting to publish an event. #{inspect(e)}")
        {:error, :publish_failed}
    end
  end

  @doc ~S"""
  Get topic name
  """
  def build_topic(prefix, id) when is_binary(prefix) and id != nil do
    ChannelsContext.event_channel().build_topic(prefix, id)
  end
end
