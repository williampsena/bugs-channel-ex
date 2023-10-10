defmodule BugsChannel.Factories.ConfigFile do
  @moduledoc """
  This is the module in charge of the test support configuration file structure.
  """

  use ExMachina

  alias BugsChannel.Factories.Service, as: ServiceFactory
  alias BugsChannel.Factories.Team, as: TeamFactory

  def config_file_factory do
    %BugsChannel.Settings.Schemas.ConfigFile{
      org: "foo",
      services: [
        ServiceFactory.service_factory()
      ],
      teams: [
        TeamFactory.team_factory()
      ],
      version: "1"
    }
  end
end
