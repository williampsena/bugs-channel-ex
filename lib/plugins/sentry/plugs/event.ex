defmodule BugsChannel.Plugins.Sentry.Plugs.Event do
  @moduledoc """
  This plug is in responsible for handling sentry issues
  """

  require Logger
  import BugsChannel.Plugs.Api
  alias BugsChannel.Events.RawEvent

  def init(options) do
    options
  end

  def call(conn, _opts) do
    action(conn, conn.method)
  end

  defp action(%Plug.Conn{params: %{"event_id" => event_id}} = conn, "POST") do
    case RawEvent.publish(event_id, "sentry", conn.params) do
      :ok ->
        send_json_resp(conn, %{"event_id" => event_id})

      error ->
        Logger.error(
          "An error occurred while attempting to send raw events: #{inspect(error)}"
        )

        send_unknown_error_resp(conn)
    end
  end

  defp action(conn, "POST") do
    IO.inspect(conn.params)
    send_unprocessable_entity_resp(conn)
  end

  defp action(conn, _) do
    send_not_found_resp(conn)
  end
end
