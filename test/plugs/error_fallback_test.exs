defmodule BugsChannel.Plugs.ErrorFallbackTest do
  use ExUnit.Case
  use Plug.Test

  alias BugsChannel.Plugs.ErrorFallback

  import BugsChannel.Test.Support.ApiHelper

  describe "fallback/2" do
    test "with valid conn should skip" do
      conn = conn(:get, "/", "")

      assert ErrorFallback.fallback(conn, conn) == conn
    end

    test "with error" do
      conn = conn(:get, "/", "")
      conn = ErrorFallback.fallback({:error, "something bad happened"}, conn)

      assert_conn(conn, 500, Jason.encode!(%{"error" => "something bad happened"}))
    end

    test "with unknown error" do
      conn = conn(:get, "/", "")
      conn = ErrorFallback.fallback({:unknown_error, "something bad happened"}, conn)

      assert_conn(conn, 500, "Internal Server Error")
    end
  end
end
