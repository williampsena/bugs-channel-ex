defmodule BugsChannel.Plugs.HealthCheckTest do
  use ExUnit.Case
  use Plug.Test

  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Plugs.HealthCheck

  test "initialize plug" do
    assert HealthCheck.init(foo: "bar") == [foo: "bar"]
  end

  test "returns health message" do
    conn =
      :get
      |> conn("/", "")
      |> HealthCheck.call([])

    assert_conn(conn, 200, "Keep calm I'm absolutely alive 🐛")
  end
end
