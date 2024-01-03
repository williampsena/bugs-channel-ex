defmodule BugsChannel.Applications.Api do
  @moduledoc """
  This is the web application module in charge of startup phoenix.
  """

  require Logger

  @doc ~S"""
  Starts web api server

  ## Examples
      iex> BugsChannel.Applications.Api.start()
      [{BugsChannel.Api.Endpoint , []}]
  """
  def start() do
    Logger.info("🌍 Starting Api...")
    [{BugsChannel.Api.Endpoint, []}]
  end
end
