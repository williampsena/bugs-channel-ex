defmodule BugsChannel.Repo.Behaviours.Service do
  @moduledoc """
  This module contains service behaviors.
  """

  alias BugsChannel.Repo.Schemas.Service

  @callback get(id :: String.t()) ::
              {:ok, service :: %Service{}} | {:error, reason :: term}

  @callback get_by_auth_key(String.t()) :: Service.t()

  @callback insert(Service.t()) :: {:ok, Service.t()} | {:error, reason :: term}
end
