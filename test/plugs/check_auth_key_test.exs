defmodule BugsChannel.Plugs.CheckAuthKeyTest do
  use BugsChannel.Case.SettingsManagerTestCase
  use Plug.Test

  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Plugs.CheckAuthKey, as: CheckAuthKeyPlug

  test "initialize plug" do
    assert CheckAuthKeyPlug.init(foo: "bar") == [foo: "bar"]
  end

  @tag :starts_with_mocks
  test "when requests there is valid x-auth-key header" do
    conn =
      :get
      |> conn("/", "")
      |> put_req_header("x-auth-key", "key")
      |> CheckAuthKeyPlug.call([])

    refute conn.halted
  end

  @tag :starts_with_mocks
  test "when requests there is invalid x-auth-key header" do
    conn =
      :get
      |> conn("/", "")
      |> put_req_header("x-auth-key", "invalid-key")
      |> CheckAuthKeyPlug.call([])

    assert conn.halted
    assert_conn(conn, 401, "Missing credentials 🪪")
  end

  @tag :starts_with_mocks
  test "when requests there is assigns" do
    conn =
      :get
      |> conn("/", "")
      |> merge_assigns(auth_key: "key")
      |> CheckAuthKeyPlug.call([])

    refute conn.halted
  end

  test "when header x-auth-key is not present" do
    conn =
      :get
      |> conn("/", "")
      |> CheckAuthKeyPlug.call([])

    assert conn.halted
    assert_conn(conn, 401, "Missing credentials 🪪")
  end
end
