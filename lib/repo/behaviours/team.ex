defmodule BugsChannel.Repo.Behaviours.Team do
  @moduledoc """
  This module contains team behaviors.
  """

  alias BugsChannel.Repo.Schemas.Team
  alias BugsChannel.Repo.Query.{PagedResults, QueryCursor}

  @type results() :: %PagedResults{
          data: maybe_improper_list(),
          meta: %{limit: integer(), offset: integer(), page: integer()}
        }

  @callback get(id :: String.t()) ::
              Service.t() | {:error, reason :: term}

  @callback list(map(), %QueryCursor{}) :: results

  @callback insert(Team.t()) :: {:ok, Team.t()} | {:error, reason :: term}

  @callback update(id :: String.t(), team :: Team.t()) ::
              {:ok, Team.t()} | {:error, reason :: term}

  @callback delete(id :: String.t()) :: :ok | {:error, reason :: term}
end
