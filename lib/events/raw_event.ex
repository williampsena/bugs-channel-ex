defmodule BugsChannel.Events.RawEvent do
  @moduledoc """
  The module is in responsible for push raw events to queue.
  """
  require Logger

  alias BugsChannel.Channels.EventChannel

  def publish(event_id, origin, message) do
    encoded_message =
      message
      |> put_origin(origin)
      |> Jason.encode!()

    event_id
    |> build_topic()
    |> EventChannel.publish(encoded_message)
  end

  defp put_origin(message, origin),
    do: Map.put(message, "x-origin", origin)

  defp build_topic(event_id) when is_binary(event_id),
    do: EventChannel.build_topic("raw-event", event_id)
end
