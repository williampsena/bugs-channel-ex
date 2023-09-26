defmodule BugsChannel.Channels.Gnat.Consumer do
  @moduledoc """
  The module is in responsible for consuming messages from NATs.
  """
  defmacro __using__(_opts) do
    quote do
      require Logger

      @behaviour Gnat.Server

      def request(message) do
        handle_subscribe(message)
      end

      def error(%{gnat: _gnat, reply_to: _reply_to}, error) do
        Logger.error(
          "An error occurred while attempting to consuming an event. #{inspect(error)}"
        )
      end

      defp handle_subscribe(%{body: body, topic: topic}) do
        case Jason.decode(body) do
          {:ok, message} ->
            dispatch_events(message, get_root_topic(topic))

          error ->
            Logger.error(
              "An error occurred while attempting to decode an event. #{inspect(error)}"
            )
        end

        :ok
      end

      defp get_root_topic(topic) when is_binary(topic) do
        topic |> String.split(".") |> List.first()
      end

      def dispatch_events(_message, _topic) do
        raise "dispatch_events/2 not implemented"
      end

      defoverridable dispatch_events: 2
    end
  end
end
