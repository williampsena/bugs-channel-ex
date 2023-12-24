defmodule BugsChannel.Events.Database.RedisPushProducer do
  @moduledoc """
  The module is in charge of pushing events to redis.
  """
  use GenServer

  require Logger

  alias BugsChannel.Repo.Schemas, as: RepoSchemas
  alias BugsChannel.Utils.Maps

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, [done: 0, errors: 0, ignored: 0]}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.warning("The redis push producer has been terminated....")
  end

  @impl true
  def handle_cast({_origin, map_event}, state) do
    event = parse_event(map_event)

    case push_event(event) do
      :ok -> {:noreply, Keyword.put(state, :done, state[:done] + 1)}
      :ignored -> {:noreply, Keyword.put(state, :ignored, state[:ignored] + 1)}
      _ -> {:noreply, state_error(state)}
    end
  rescue
    e ->
      Logger.error(
        "❌ An unexpected error occurred while attempting to push events to Redis.#{inspect(e)}"
      )

      {:noreply, state_error(state)}
  end

  def enqueue(origin, event) do
    Logger.debug("Enqueue an event from #{origin}: #{inspect(event)} to push at redis database")
    GenServer.cast(__MODULE__, {origin, event})
  end

  defp parse_event(map_event) do
    case RepoSchemas.Event.parse(map_event) do
      {:ok, event} -> event
      _ -> :invalid_event
    end
  end

  defp state_error(state),
    do: Keyword.put(state, :errors, state[:errors] + 1)

  defp push_event(%RepoSchemas.Event{} = event) do
    case Redix.command(:redix, ["LPUSH", "events", encode_event(event)]) do
      {:ok, _} ->
        Logger.debug("🔥 The event(#{event.id}) was successfully created.")
        :ok

      error ->
        Logger.error(
          "❌ An error occurred while attempting to push an event on database. #{inspect(error)}"
        )

        error
    end
  end

  defp push_event(event) do
    Logger.warning("The event #{event} was ignored.")
    :ignored
  end

  defp encode_event(%RepoSchemas.Event{} = event) do
    event
    |> Maps.map_from_struct()
    |> Jason.encode!()
  end
end
