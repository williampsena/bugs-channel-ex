defmodule BugsChannel.Repo.TeamTest do
  use ExUnit.Case

  import BugsChannel.Factories.Team
  import Mox

  alias BugsChannel.Repo.Query.QueryCursor
  alias BugsChannel.Repo, as: Repo

  setup :verify_on_exit!

  setup do
    team = build(:team)

    {:ok, inserted_team} =
      Repo.Team.insert(team)

    [team: team, team_id: "#{inserted_team.id}"]
  end

  describe "get/1" do
    test "when a team is not found" do
      assert Repo.Team.get("657529b00000000000000000") == nil
    end

    test "when a team is found", %{team_id: team_id} do
      assert match?(
               %BugsChannel.Repo.Schemas.Team{
                 name: "foo"
               },
               Repo.Team.get(team_id)
             )
    end
  end

  describe "insert/1" do
    test "when a team is valid" do
      team = build(:team)
      assert {:ok, inserted_team} = Repo.Team.insert(team)
      assert match?(%BugsChannel.Repo.Schemas.Team{}, inserted_team)
      refute is_nil(inserted_team.id)
    end
  end

  describe "update/1" do
    test "when a team is valid", %{team_id: team_id} do
      assert Repo.Team.update(team_id, %{"name" => "updated"}) == :ok
    end
  end

  describe "list/1" do
    test "when there is no team" do
      assert Repo.Team.list(%{"name" => "bug"}) == %BugsChannel.Repo.Query.PagedResults{
               data: [],
               meta: %{count: 0, offset: 0, limit: 25, page: 0},
               local: %{empty: true}
             }
    end

    test "when a team is found", %{team: team} do
      team = Map.put(team, :name, "bug team")

      {:ok, inserted_team} =
        Repo.Team.insert(team)

      teams = Repo.Team.list(%{"name" => team.name})
      count = Kernel.length(teams.data)

      assert teams.local == %{
               empty: false,
               next_page: %QueryCursor{offset: 25, limit: 25, page: 1}
             }

      assert teams.meta == %{limit: 25, offset: 0, page: 0, count: count}

      assert List.first(teams.data) == inserted_team
    end
  end

  describe "delete/1" do
    test "when a team exists", %{team: team} do
      team = Map.put(team, :name, "delete team")

      {:ok, inserted_team} =
        Repo.Team.insert(team)

      assert Repo.Team.delete("#{inserted_team.id}") == :ok
    end

    test "when a team does not exists" do
      assert Repo.Team.delete("38c865300000000000000000") ==
               {:error, :not_found_error, "The document could not be found."}
    end
  end
end
