defmodule BugsChannel.Repo.Behaviours.Event do
  @moduledoc """
  This module contains event behaviors.
  """

  alias BugsChannel.Repo.Schemas.Event

  @callback get(id :: String.t()) ::
              {:ok, service :: %Event{}} | {:error, reason :: term}

  @callback list(String.t()) :: list(Event.t())

  @callback insert(Event.t()) :: {:ok, Event.t()} | {:error, reason :: term}
end
