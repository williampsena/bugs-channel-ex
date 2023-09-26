defmodule BugsChannel.Channels.Behaviours.Channel do
  @moduledoc """
  This module contains channel behaviors.
  """

  @callback publish(state :: String.t(), message :: String.t()) ::
              {:ok, new_state :: term} | {:error, reason :: term}

  @callback build_topic(topic :: String.t(), id :: String.t()) :: String.t()
end