defmodule BugsChannel.Channels.Context do
  @moduledoc """
  This module contains channel context.
  """

  def event_channel(), do: channels()[:event_channel]
  def channels(), do: Application.get_env(:bugs_channel, :channels)
end
