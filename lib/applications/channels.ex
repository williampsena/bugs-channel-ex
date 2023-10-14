defmodule BugsChannel.Applications.Channels do
  @moduledoc """
  This is the gnat application module in charge of startup processes.
  """

  require Logger

  @doc ~S"""
  Starts gnat gen server supervisor

  ## Examples

      iex> BugsChannel.Applications.Channels.start()
      [ {BugsChannel.Events.Producer, []} ]
  """
  def start() do
    Logger.info("⚙️ Starting GenStages...")

    [
      {BugsChannel.Events.Producer, []}
    ]
  end
end
