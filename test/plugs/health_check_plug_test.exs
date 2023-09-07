defmodule BugsChannel.Plugs.HealthCheckTest do
  use ExUnit.Case
  use Plug.Test

  alias BugsChannel.Plugs.HealthCheck

  test "returns health message" do
    conn =
      :get
      |> conn("/", "")
      |> HealthCheck.call([])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Keep calm I'm absolutely alive 🐛"
  end
end
