defmodule BugsChannel.Events.Producer do
  @moduledoc """
  The module is in charge of creating events.
  """
  use GenServer

  require Logger

  alias BugsChannel.Repo.Schemas.Event
  alias BugsChannel.Events.{Scrubber, EventPublisher}
  alias BugsChannel.Plugins.Sentry.Event, as: SentryEvent

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, [events: [], events_missed: 0]}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.warning("The event producer has been terminated....")
  end

  @impl true
  def handle_cast({origin, events}, state) do
    events =
      origin
      |> parse_events(events)
      |> maybe_scrub_list()

    case publish_events(events) do
      %{errors: 0} ->
        event_ids = Enum.map(events, & &1[:id])
        {:noreply, Keyword.put(state, :events, event_ids ++ state[:events])}

      _ ->
        {:noreply, Keyword.put(state, :events_missed, state[:events_missed] + 1)}
    end
  end

  defp publish_events(events) when is_list(events) do
    Enum.reduce(events, %{done: 0, errors: 0}, fn event, acc ->
      case EventPublisher.publish(event.id, event) do
        :ok ->
          Map.put(acc, :done, acc[:done] + 1)

        error ->
          Logger.error("❌ An error occurred while attempting to push an event. #{inspect(error)}")
          Map.put(acc, :errors, acc[:errors] + 1)
      end
    end)
  end

  defp publish_events(_events), do: []

  def enqueue(origin, event) do
    Logger.debug("Enqueue an event from #{origin}: #{inspect(event)}")
    GenServer.cast(__MODULE__, {origin, event})
  end

  defp parse_events(origin, raw_event) do
    events =
      case origin do
        :sentry ->
          SentryEvent.parse_to_event(raw_event)

        _ ->
          Event.parse(raw_event)
      end

    with {:ok, event} <- events do
      if is_list(event), do: event, else: [event]
    end
  end

  defp maybe_scrub_list(events) when is_list(events) do
    Scrubber.scrub_list(events)
  end

  defp maybe_scrub_list({:error, error}) do
    Logger.error("❌ An error occurred while attempting to parse an event. #{inspect(error)}")
  end
end
