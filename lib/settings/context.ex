defmodule BugsChannel.Settings.Context do
  @moduledoc """
  This module contains settings context.
  """

  @spec manager :: BugsChannel.Settings.Manager
  def manager(), do: settings()[:manager]

  def settings(), do: Application.get_env(:bugs_channel, :settings)
end
