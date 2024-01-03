defmodule BugsChannel.Api.Controllers.HealthCheckTest do
  use ExUnit.Case
  use Plug.Test

  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Api.Controllers.HealthCheck, as: HealthCheckController

  test "returns health message" do
    conn =
      :get
      |> conn("/", "")
      |> HealthCheckController.index(%{})

    assert_conn(conn, 200, "Keep calm I'm absolutely alive 🐛")
  end
end
