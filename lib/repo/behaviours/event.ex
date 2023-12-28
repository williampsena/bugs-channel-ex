defmodule BugsChannel.Repo.Behaviours.Event do
  @moduledoc """
  This module contains event behaviors.
  """

  alias BugsChannel.Repo.Schemas.Event
  alias BugsChannel.Repo.Query.{PagedResults, QueryCursor}

  @callback get(id :: String.t()) ::
              {:ok, service :: %Event{}} | {:error, reason :: term}

  @callback list_by_service(String.t(), %QueryCursor{}) :: %PagedResults{data: list(Event.t())}

  @callback list(:map, %QueryCursor{}) :: %PagedResults{data: list(Event.t())}

  @callback insert(Event.t()) :: {:ok, Event.t()} | {:error, reason :: term}
end
