defmodule BugsChannel.Applications.Settings do
  @moduledoc """
  This is the settings application module in charge of startup agent server.
  """

  require Logger

  @doc ~S"""
  Starts settings manager agent

  ## Examples

      iex> BugsChannel.Applications.Settings.start("sql")
      []

      iex> BugsChannel.Applications.Settings.start("dbless")
      [{BugsChannel.Settings.Manager, []}]
  """
  def start(database_mode) do
    if database_mode == "dbless",
      do: do_start(),
      else: []
  end

  defp do_start() do
    Logger.info("📝 Starting Dbless agent...")
    [{BugsChannel.Settings.Manager, []}]
  end
end
