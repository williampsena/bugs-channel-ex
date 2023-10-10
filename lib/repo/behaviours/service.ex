defmodule BugsChannel.Repo.Behaviours.Service do
  @moduledoc """
  This module contains service behaviors.
  """

  alias BugsChannel.Repo.Schemas.Service

  @callback get(id :: String.t()) ::
              {:ok, service :: %Service{}} | {:error, reason :: term}
end
