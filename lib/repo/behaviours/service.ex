defmodule BugsChannel.Repo.Behaviours.Service do
  @moduledoc """
  This module contains service behaviors.
  """

  alias BugsChannel.Repo.Schemas.Service
  alias BugsChannel.Repo.Query.{PagedResults, QueryCursor}

  @type results() :: %PagedResults{
          data: maybe_improper_list(),
          meta: %{limit: integer(), offset: integer(), page: integer()}
        }

  @callback get(id :: String.t()) ::
              Service.t() | {:error, reason :: term}

  @callback get_by_auth_key(String.t()) :: Service.t()

  @callback list(map(), %QueryCursor{}) :: results

  @callback insert(Service.t()) :: {:ok, Service.t()} | {:error, reason :: term}
end
