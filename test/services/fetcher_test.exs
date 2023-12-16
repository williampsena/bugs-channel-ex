defmodule BugsChannel.Services.FetcherTest do
  use BugsChannel.Case.SettingsManagerTestCase
  import BugsChannel.Factories.Service

  alias BugsChannel.Services.Fetcher, as: ServicesFetcher

  setup do
    setup_manager_mocks_expectations()

    service = build(:service)

    config_file =
      %BugsChannel.Settings.Schemas.ConfigFile{
        org: "foo",
        services: [
          service
        ],
        teams: [
          %BugsChannel.Repo.Schemas.Team{
            id: "1",
            name: "foo"
          }
        ],
        version: "1"
      }

    [config_file: config_file, service: service]
  end

  describe "get/1" do
    test "with valid service", %{service: service} do
      assert ServicesFetcher.get("1") == service
    end

    test "with invalid service" do
      assert ServicesFetcher.get("99") == nil
    end
  end

  describe "get_by_auth_key/1" do
    test "with valid service", %{service: service} do
      assert ServicesFetcher.get_by_auth_key("key") == service
    end

    test "with invalid service" do
      assert ServicesFetcher.get_by_auth_key("invalid-key") == nil
    end
  end
end
