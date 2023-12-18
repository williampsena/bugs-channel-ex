defmodule BugsChannel.Repo.BaseTest do
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

  describe "get_by_id/2" do
    test "when document is not found" do
      assert Repo.Base.get_by_id("services", "657529b00000000000000000") == nil
    end

    test "when a document is found", %{service_id: service_id} do
      assert match?(
               %{
                 "auth_keys" => [
                   %{
                     "disabled" => false,
                     "expired_at" => nil,
                     "key" => "key"
                   },
                   %{
                     "disabled" => false,
                     "expired_at" => 946_684_800,
                     "key" => "expired_key"
                   },
                   %{
                     "disabled" => true,
                     "expired_at" => nil,
                     "key" => "disabled_key"
                   }
                 ],
                 "name" => "foo bar service",
                 "platform" => "python",
                 "settings" => %{"rate_limit" => 1},
                 "teams" => [
                   %{
                     "name" => "foo"
                   }
                 ]
               },
               Repo.Base.get_by_id("services", service_id)
             )
    end
  end

  describe "find/2" do
    test "when a document is not found" do
      assert Repo.Base.find("services", %{_id: BSON.ObjectId.decode!("657529b00000000000000000")}) ==
               []
    end

    test "when a document is found", %{service_id: service_id} do
      assert match?(
               [
                 %{
                   "auth_keys" => [
                     %{
                       "disabled" => false,
                       "expired_at" => nil,
                       "key" => "key"
                     },
                     %{
                       "disabled" => false,
                       "expired_at" => 946_684_800,
                       "key" => "expired_key"
                     },
                     %{
                       "disabled" => true,
                       "expired_at" => nil,
                       "key" => "disabled_key"
                     }
                   ],
                   "name" => "foo bar service",
                   "platform" => "python",
                   "settings" => %{"rate_limit" => 1},
                   "teams" => [
                     %{
                       "name" => "foo"
                     }
                   ]
                 }
               ],
               Repo.Base.find("services", %{_id: BSON.ObjectId.decode!(service_id)})
             )
    end
  end

  describe "insert/2" do
    test "when a document is valid" do
      service = build(:service)
      assert {:ok, inserted_service} = Repo.Base.insert("services", service)
      assert match?(%BugsChannel.Repo.Schemas.Service{}, inserted_service)
      refute is_nil(inserted_service.id)
    end
  end
end
