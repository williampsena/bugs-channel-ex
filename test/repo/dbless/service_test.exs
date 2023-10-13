defmodule BugsChannel.Repo.DBLess.ServiceTest do
  use BugsChannel.Case.SettingsManagerTestCase
  import BugsChannel.Factories.Service
  import Mox

  alias BugsChannel.Repo.DBless, as: Repo

  setup :verify_on_exit!

  setup do
    service = build(:service)

    Application.put_env(:bugs_channel, :config_file, "test/fixtures/settings/config.yml")

    [service: service]
  end

  describe "get/1" do
    @tag :starts_with_mocks
    test "when a service is found", %{service: service} do
      assert Repo.Service.get(1) == service
    end

    @tag :starts_with_mocks
    test "when a service is not found" do
      assert Repo.Service.get(2) == nil
    end
  end

  describe "get_by_auth_key/1" do
    @tag :starts_with_mocks
    test "when a service is found", %{service: service} do
      assert Repo.Service.get_by_auth_key("key") == service
    end

    @tag :starts_with_mocks
    test "when a service is not found" do
      assert Repo.Service.get_by_auth_key("invalid_key") == nil
    end

    @tag :starts_with_mocks
    test "when a service is not found because there is expired key" do
      assert Repo.Service.get_by_auth_key("expired_key") == nil
    end

    @tag :starts_with_mocks
    test "when a service is not found because there is disabled key" do
      assert Repo.Service.get_by_auth_key("disabled_key") == nil
    end
  end
end
