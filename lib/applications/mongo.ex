defmodule BugsChannel.Applications.Mongo do
  @moduledoc """
  This is the mongo application module in charge of startup mongo processes.
  """

  @doc ~S"""
  Starts mongo gen server

  ## Examples

      iex> BugsChannel.Applications.Mongo.start("sql", [foo: :bar])
      []

      iex> BugsChannel.Applications.Mongo.start("mongo", "wrong args")
      []

      iex> BugsChannel.Applications.Mongo.start("mongo", [ connection_url: "mongodb://localhost:27017/bugs-channel" ])
      {Mongo, [url: "mongodb://localhost:27017/bugs-channel"]}

      iex> BugsChannel.Applications.Mongo.start("mongo")
      []
  """
  def start(database_mode, config \\ nil) when is_binary(database_mode) do
    config = config || mongo_config()
    do_start(database_mode, config)
  end

  defp do_start("mongo", config) when is_list(config) do
    {Mongo, [url: config[:connection_url]]}
  end

  defp do_start(_database_mode, _config), do: []

  defp mongo_config(), do: Application.get_env(:bugs_channel, :mongo)
end
