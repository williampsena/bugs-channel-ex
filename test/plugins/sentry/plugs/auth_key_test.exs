defmodule BugsChannel.Plugins.Sentry.Plugs.AuthKeyTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Plugins.Sentry.Plugs.AuthKey, as: SentryAuthKeyPlug

  test "initialize plug" do
    assert SentryAuthKeyPlug.init(no: "args") == [no: "args"]
  end

  test "when header x-sentry-auth is present" do
    conn =
      :get
      |> conn("/", "")
      |> put_req_header(
        "x-sentry-auth",
        "Sentry sentry_key=foo-bar, sentry_version=7, sentry_client=sentry.python/1.30.0"
      )
      |> SentryAuthKeyPlug.call([])

    refute conn.halted
    assert conn.assigns[:auth_key] == "foo-bar"
  end

  test "when header sentry-key is present" do
    conn =
      :get
      |> conn("/?sentry_key=foo-bar", "")
      |> SentryAuthKeyPlug.call([])

    refute conn.halted
    assert conn.assigns[:auth_key] == "foo-bar"
  end

  test "when header x-sentry-auth is not present" do
    conn =
      :get
      |> conn("/", "")
      |> SentryAuthKeyPlug.call([])

    assert conn.halted
    assert_conn(conn, 401, "Missing credentials 🪪")
  end

  test "when header x-sentry-auth is present with bad format" do
    conn =
      :get
      |> conn("/", "")
      |> put_req_header("x-sentry-auth", "foo-bar")
      |> SentryAuthKeyPlug.call([])

    assert conn.halted
    assert_conn(conn, 401, "Missing credentials 🪪")
  end
end
