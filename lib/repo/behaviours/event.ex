defmodule BugsChannel.Repo.Behaviours.Event do
  @moduledoc """
  This module contains event behaviors.
  """
  alias BugsChannel.Repo.Schemas.Event
  alias BugsChannel.Repo.Query.{PagedResults, QueryCursor}

  @type results() :: %PagedResults{
          data: maybe_improper_list(),
          meta: %{limit: integer(), offset: integer(), page: integer()}
        }

  @callback get(id :: String.t()) ::
              {:ok, service :: %Event{}} | {:error, reason :: term}

  @callback list_by_service(String.t(), %QueryCursor{}) :: results

  @callback list(map(), %QueryCursor{}) :: results

  @callback insert(Event.t()) :: {:ok, Event.t()} | {:error, reason :: term}
end
