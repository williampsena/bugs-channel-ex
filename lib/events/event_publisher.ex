defmodule BugsChannel.Events.EventPublisher do
  @moduledoc """
  The module is in responsible for push events to queue.
  """
  require Logger

  alias BugsChannel.Channels.EventChannel

  def publish(event_id, message) do
    event_id
    |> build_topic()
    |> EventChannel.publish(Jason.encode!(message))
  end

  defp build_topic(event_id) when is_binary(event_id) do
    EventChannel.build_topic("event", event_id)
  end
end
