defmodule BugsChannel.Api.Controllers.ServiceTest do
  use ExUnit.Case
  use Plug.Test

  import Mock
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

  describe "GET /service/:id" do
    test "returns not found" do
      service_id = "657529b00000000000000000"

      conn =
        :get
        |> conn("/service/#{service_id}", "")
        |> ServiceController.show(%{"id" => service_id})

      assert_conn(conn, 404, "Oops! 👀")
    end

    test "returns a service", %{service: service, service_id: service_id} do
      conn =
        :get
        |> conn("/service/#{service_id}", "")
        |> ServiceController.show(%{"id" => service_id})

      service_map = service |> Maps.map_from_struct() |> Jason.encode!()

      assert_conn(conn, 200, service_map)
    end
  end

  describe "POST /service" do
    setup do
      service_params = %{
        "name" => "foo bar service",
        "platform" => "python",
        "teams" => [%{"id" => "1", "name" => "foo"}],
        "settings" => %{"rate_limit" => 1},
        "auth_keys" => [%{"key" => "123"}]
      }

      [service_params: service_params]
    end

    test "with success", %{service_params: service_params} do
      conn =
        :post
        |> conn("/service", "")
        |> ServiceController.create(service_params)

      assert_conn(conn, 204, "")
    end

    test "with validation error", %{service_id: service_id} do
      conn =
        :post
        |> conn("/service", "")
        |> ServiceController.create(%{"id" => service_id})

      assert_conn(
        conn,
        422,
        Jason.encode!(%{"error" => ["name: can't be blank", "platform: can't be blank"]})
      )
    end

    test "with error", %{service_params: service_params} do
      error = "invalid connection"

      with_mock(Repo.Service, [:passthrough], insert: fn _service -> {:error, error} end) do
        conn =
          :post
          |> conn("/service", "")
          |> ServiceController.create(service_params)

        assert_conn(conn, 500, %{"error" => error})
      end
    end
  end
end
