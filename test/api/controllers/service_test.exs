defmodule BugsChannel.Api.Controllers.ServiceTest do
  use ExUnit.Case
  use Plug.Test

  import BugsChannel.Factories.Service
  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Utils.Maps
  alias BugsChannel.Repo, as: Repo
  alias BugsChannel.Api.Controllers.Service, as: ServiceController

  setup do
    service = build(:service)

    {:ok, inserted_service} =
      Repo.Service.insert(service)

    [service: inserted_service, service_id: "#{inserted_service.id}"]
  end

  test "returns not found" do
    conn =
      :get
      |> conn("/", "")
      |> ServiceController.show(%{"id" => "657529b00000000000000000"})

    assert_conn(conn, 404, "Oops! 👀")
  end

  test "returns a service", %{service: service, service_id: service_id} do
    conn =
      :get
      |> conn("/", "")
      |> ServiceController.show(%{"id" => service_id})

    service_map = service |> Maps.map_from_struct() |> Jason.encode!()

    assert_conn(conn, 200, service_map)
  end
end
