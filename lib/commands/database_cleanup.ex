defmodule BugsChannel.Commands.DatabaseCleanup do
  @moduledoc """
  This modules is in charge to reset database for test/dev environment
  """

  require Logger
  alias BugsChannel.Utils.ConnectionParamsBuilder

  def run(_args) do
    if Mix.env() == :prod,
      do:
        raise(
          ArgumentError,
          "This task hadn't been designed to be run in a production environment. 🥺"
        )

    Logger.debug("Resetting database...")

    connection_url = mongo_connection_url()
    database = get_mongo_database_name(connection_url)

    {:ok, _pid} = start_link(connection_url)

    if is_nil(database) || database == "",
      do: raise(ArgumentError, "The mongo connection is invalid. 😔")

    Mongo.drop_database(:mongo_admin, database)

    Logger.debug("The database #{database} was cleanup")
  end

  defp start_link(connection_url) do
    Mongo.start_link(name: :mongo_admin, url: connection_url)
  end

  defp mongo_connection_url() do
    Application.get_env(:bugs_channel, :mongo)[:connection_url]
  end

  defp get_mongo_database_name(connection_url) do
    {_, conn_params} = ConnectionParamsBuilder.from_url(connection_url)

    Map.get(conn_params, :path)
  end
end
