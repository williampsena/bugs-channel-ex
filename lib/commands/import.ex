defmodule BugsChannel.Commands.Import do
  @moduledoc """
  This modules is in charge to import yaml file to database
  """

  require Logger

  alias BugsChannel.Settings.Manager, as: SettingsManager
  alias BugsChannel.Settings.Schemas.ConfigFile
  alias BugsChannel.Utils.Maps

  def run(args) do
    dump_file = List.first(args)

    IO.puts("Importing dump file...")

    if is_nil(dump_file),
      do: raise(ArgumentError, "Please provide the dump file location. 🥺")

    case SettingsManager.load_from_file(dump_file) do
      {:ok, settings} ->
        do_import(settings)

      error ->
        Logger.debug(inspect(error))
        raise(ArgumentError, "The dump file is in the wrong format. 😔")
    end
  end

  defp do_import(%ConfigFile{} = settings) do
    insert_teams(settings)
    insert_services(settings)

    Logger.info("The dump was imported, and the database was completed.")
  end

  defp insert_teams(%ConfigFile{teams: teams}) do
    Enum.each(teams, fn team ->
      with {:error, error} <-
             Mongo.update_one(:mongo, "teams", %{name: team.name}, %{"$set" => build_map(team)},
               upsert: true
             ) do
        Logger.warning(
          "❌ An error occurred while attempting to insert a team(#{team.id}) into the database. #{inspect(error)}"
        )
      end
    end)
  end

  defp insert_services(%ConfigFile{services: services}) do
    Enum.each(services, fn service ->
      with {:error, error} <-
             Mongo.update_one(
               :mongo,
               "services",
               %{name: service.name},
               %{"$set" => build_map(service)},
               upsert: true
             ) do
        Logger.warning(
          "❌ An error occurred while attempting to insert a service(#{service.id}) into the database. #{inspect(error)}"
        )
      end
    end)
  end

  defp build_map(schema) do
    schema
    |> Map.delete(:id)
    |> Maps.map_from_struct()
  end
end
