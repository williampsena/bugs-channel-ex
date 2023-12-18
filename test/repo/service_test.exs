defmodule BugsChannel.Repo.ServiceTest do
  use ExUnit.Case

  import BugsChannel.Factories.Service
  import Mox

  alias BugsChannel.Repo, as: Repo

  setup :verify_on_exit!

  setup do
    service = build(:service)

    {:ok, inserted_service} =
      Repo.Service.insert(service)

    [service: service, service_id: "#{inserted_service.id}"]
  end

  describe "get/1" do
    test "when a service is not found" do
      assert Repo.Service.get("657529b00000000000000000") == nil
    end

    test "when a service is found", %{service_id: service_id} do
      assert match?(
               %BugsChannel.Repo.Schemas.Service{
                 auth_keys: [
                   %BugsChannel.Repo.Schemas.ServiceAuthKey{
                     disabled: false,
                     expired_at: nil,
                     key: "key"
                   },
                   %BugsChannel.Repo.Schemas.ServiceAuthKey{
                     disabled: false,
                     expired_at: 946_684_800,
                     key: "expired_key"
                   },
                   %BugsChannel.Repo.Schemas.ServiceAuthKey{
                     disabled: true,
                     expired_at: nil,
                     key: "disabled_key"
                   }
                 ],
                 name: "foo bar service",
                 platform: "python",
                 settings: %BugsChannel.Repo.Schemas.ServiceSettings{rate_limit: 1},
                 teams: [
                   %BugsChannel.Repo.Schemas.Team{
                     name: "foo"
                   }
                 ]
               },
               Repo.Service.get(service_id)
             )
    end
  end

  describe "get_by_auth_key/1" do
    test "when a service is not found" do
      assert Repo.Service.get_by_auth_key("unknown_key") == nil
    end

    test "when a service is found" do
      assert match?(
               %BugsChannel.Repo.Schemas.Service{
                 auth_keys: [
                   %BugsChannel.Repo.Schemas.ServiceAuthKey{
                     disabled: false,
                     expired_at: nil,
                     key: "key"
                   },
                   %BugsChannel.Repo.Schemas.ServiceAuthKey{
                     disabled: false,
                     expired_at: 946_684_800,
                     key: "expired_key"
                   },
                   %BugsChannel.Repo.Schemas.ServiceAuthKey{
                     disabled: true,
                     expired_at: nil,
                     key: "disabled_key"
                   }
                 ],
                 name: "foo bar service",
                 platform: "python",
                 settings: %BugsChannel.Repo.Schemas.ServiceSettings{rate_limit: 1},
                 teams: [
                   %BugsChannel.Repo.Schemas.Team{
                     name: "foo"
                   }
                 ]
               },
               Repo.Service.get_by_auth_key("key")
             )
    end
  end

  describe "insert/1" do
    test "when a service is valid" do
      service = build(:service)
      assert {:ok, inserted_service} = Repo.Service.insert(service)
      assert match?(%BugsChannel.Repo.Schemas.Service{}, inserted_service)
      refute is_nil(inserted_service.id)
    end
  end
end