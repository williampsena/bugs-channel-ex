defmodule BugsChannel.Factories.Team do
  @moduledoc """
  This is the module in charge of the test teams structure.
  """

  use ExMachina

  def team_factory do
    %BugsChannel.Repo.Schemas.Team{
      id: "1",
      name: "foo"
    }
  end
end
