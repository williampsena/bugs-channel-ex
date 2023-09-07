defmodule BugsChannel.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias BugsChannel.Router

  test "returns not found" do
    conn =
      :get
      |> conn("/", "")
      |> Router.call([])

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Oops! 👀"
  end

  test "returns health check response" do
    conn =
      :get
      |> conn("/health_check", "")
      |> Router.call([])

    assert conn.state == :sent
    assert conn.status == 200
  end
end
