defmodule BugsChannel.Api.Decorators.ParamsValidatorTest do
  use ExUnit.Case
  use Plug.Test

  import BugsChannel.Test.Support.ApiHelper
  import BugsChannel.Plugs.Api

  alias BugsChannel.Repo.Parsers
  alias BugsChannel.Api.Decorators.ParamsValidator

  use ParamsValidator

  @decorate validate_params(Parsers.Service)
  def test_validate_params(%Plug.Conn{} = conn, params) do
    case params do
      %{"name" => _} -> send_no_content(conn)
      _ -> send_unknown_error_resp(conn)
    end
  end

  describe "validate_params/1" do
    test "returns validation error" do
      conn =
        :post
        |> conn("/service}", "")
        |> test_validate_params(%{"fake" => "payload"})

      assert_conn(
        conn,
        422,
        Jason.encode!(%{"error" => ["name: can't be blank", "platform: can't be blank"]})
      )
    end

    test "returns api ok" do
      conn =
        :post
        |> conn("/service}", "")
        |> test_validate_params(%{"name" => "foo", "platform" => "bar"})

      assert_conn(conn, 204, "")
    end
  end
end
