defmodule BugsChannel.Api.RouterTest do
  use ExUnit.Case
  use Plug.Test

  import Mock
  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Api.Router
  alias BugsChannel.Api.Controllers.HealthCheck, as: HealthCheckController

  test "returns not found" do
    conn =
      :get
      |> conn("/", "")
      |> Router.call([])

    assert_conn(conn, 404, "Oops! 👀")
  end

  test "returns unknown error" do
    with_mock(HealthCheckController, [:passthrough], index: fn _, _ -> raise "oops" end) do
      conn = conn(:get, "/health_check")

      assert_raise Plug.Conn.WrapperError, "** (RuntimeError) oops", fn ->
        Router.call(conn, [])
      end

      assert_received {:plug_conn, :sent}
      assert {500, _headers, "Something went wrong 😦"} = sent_resp(conn)
    end
  end

  describe "health check route" do
    test "returns /health_check response" do
      conn =
        :get
        |> conn("/health_check", "")
        |> Router.call([])

      assert_conn(conn, 200, "Keep calm I'm absolutely alive 🐛")
    end
  end

  describe "service routes" do
    test "returns /service/:id some response" do
      conn =
        :get
        |> conn("/service/657529b00000000000000000", "")
        |> Router.call([])

      assert_conn(conn, 404, "Oops! 👀")
    end
  end
end
