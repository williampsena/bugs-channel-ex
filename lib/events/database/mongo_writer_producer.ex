defmodule BugsChannel.Events.Database.MongoWriterProducer do
  @moduledoc """
  The module is in charge of creating events.
  """
  use GenServer

  require Logger

  alias BugsChannel.Repo
  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, [done: 0, errors: 0, ignored: 0]}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.warning("The mongo writer producer has been terminated....")
  end

  @impl true
  def handle_cast({_origin, map_event}, state) do
    event = parse_event(map_event)


    case write_event(event) do
      :ok -> {:noreply, Keyword.put(state, :done, state[:done] + 1)}
      :ignored -> {:noreply, Keyword.put(state, :ignored, state[:ignored] + 1)}
      _ -> {:noreply, state_error(state)}
    end
  rescue
    e ->
      Logger.error(
        "❌ An unexpected error occurred while attempting to write events to MongoDB.#{inspect(e)}"
      )

      {:noreply, state_error(state)}
  end

  def enqueue(origin, event) do
    Logger.debug("Enqueue an event from #{origin}: #{inspect(event)} to write at mongo database")
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

  defp write_event(%RepoSchemas.Event{} = event) do
    case Repo.Event.insert(event) do
      {:ok, _} ->
        Logger.debug("🔥 The event(#{event.id}) was successfully created.")
        :ok

      error ->
        Logger.error(
          "❌ An error occurred while attempting to save an event on database. #{inspect(error)}"
        )

        error
    end
  end

  defp write_event(event) do
    Logger.warning("The event #{event} was ignored.")
    :ignored
  end
end
