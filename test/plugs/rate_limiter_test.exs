defmodule BugsChannel.Plugs.RateLimiterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Plugs.RateLimiter, as: RateLimiterPlug

  test "initialize plug" do
    assert RateLimiterPlug.init(key: "args") == [
             limit: 3,
             ttl: 60_000,
             by: [:header, "x-api-key"],
             key: "args"
           ]

    assert RateLimiterPlug.init([]) == [
             limit: 3,
             ttl: 60_000,
             by: [:header, "x-api-key"],
             key: "_"
           ]
  end

  test "when requests is less than the limit" do
    conn =
      :get
      |> conn("/", "")
      |> put_req_header("x-key", "foo")
      |> RateLimiterPlug.call(key: "foo", by: [:header, "x-key"], ttl: 5_000, limit: 3)

    refute conn.halted
  end

  test "when requests uses assigns" do
    conn =
      :get
      |> conn("/", "")
      |> merge_assigns([foo: "bar"])
      |> RateLimiterPlug.call(key: "foo", by: [:assigns, "foo"], ttl: 5_000, limit: 3)

    refute conn.halted
  end

  test "when requests is greater than the limit" do
    call_plug = fn ->
      :get
      |> conn("/", "")
      |> put_req_header("x-key", "foo")
      |> RateLimiterPlug.call(key: "bar", by: [:header, "x-key"], ttl: 30_000, limit: 1)
    end

    call_plug.()
    conn = call_plug.()

    assert conn.halted
    assert_conn(conn, 429, "Too Many Requests 😫")
    assert {"x-rate-limit", "1"} in conn.resp_headers
  end
end
