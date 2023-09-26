defmodule BugsChannel.RouterTest do
  use ExUnit.Case
  use Plug.Test

  import Mock
  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Router
  alias BugsChannel.Plugs.HealthCheck, as: HealthCheckPlug

  test "returns not found" do
    conn =
      :get
      |> conn("/", "")
      |> Router.call([])

    assert_conn(conn, 404, "Oops! 👀")
  end

  test "returns unknown error" do
    with_mock(HealthCheckPlug, [:passthrough], call: fn _, _ -> raise "oops" end) do
      conn = conn(:get, "/health_check")

      assert_raise Plug.Conn.WrapperError, "** (RuntimeError) oops", fn ->
        Router.call(conn, [])
      end

      assert_received {:plug_conn, :sent}
      assert {500, _headers, "Something went wrong 😦"} = sent_resp(conn)
    end
  end

  test "returns health check response" do
    conn =
      :get
      |> conn("/health_check", "")
      |> Router.call([])

    assert_conn(conn, 200, "Keep calm I'm absolutely alive 🐛")
  end
end
