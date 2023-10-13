defmodule BugsChannel.Plugins.Sentry.RouterTest do
  use BugsChannel.Case.SettingsManagerTestCase
  use Plug.Test

  import Mock
  import Plug.Conn
  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Plugins.Sentry.Router
  alias BugsChannel.Plugins.Sentry.Plugs.Event, as: SentryEventPlug

  @sentry_auth_header "Sentry sentry_key=key, sentry_version=7, sentry_client=sentry.python/1.30.0"

  @tag :starts_with_mocks
  test "returns not found" do
    conn =
      :get
      |> conn("/", "")
      |> put_req_header("x-sentry-auth", @sentry_auth_header)
      |> Router.call([])

    assert_conn(conn, 404, "Oops! 👀")
  end

  @tag :starts_with_mocks
  test "returns unknown error" do
    with_mock(SentryEventPlug, [:passthrough], call: fn _, _ -> raise "oops" end) do
      conn =
        :post
        |> conn("/api/1/envelope")
        |> put_req_header("x-sentry-auth", @sentry_auth_header)

      assert_raise Plug.Conn.WrapperError, "** (RuntimeError) oops", fn ->
        Router.call(conn, [])
      end

      assert_received {:plug_conn, :sent}
      assert {500, _headers, "Something went wrong 😦"} = sent_resp(conn)
    end
  end

  @tag :starts_with_mocks
  test "forward sentry event" do
    with_mock(SentryEventPlug, [:passthrough], call: fn conn, _ -> send_resp(conn, 204, "") end) do
      conn =
        :post
        |> conn("/api/1/envelope")
        |> put_req_header("x-sentry-auth", @sentry_auth_header)

      conn = Router.call(conn, [])

      assert_conn(conn, 204, "")
    end
  end
end
