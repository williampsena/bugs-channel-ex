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

    test "with unprocessable entity error (ecto)" do
      conn = conn(:get, "/", "")

      conn =
        ErrorFallback.fallback(
          {:error,
           %Ecto.Changeset{
             valid?: false,
             errors: [
               foo: :bar,
               service_id: {"is invalid", [type: :integer, validation: :cast]},
               stack_trace: {"is invalid", [type: {:array, :map}, validation: :cast]}
             ]
           }},
          conn
        )

      assert_conn(conn, 422, %{
        "error" => ["foo: :bar", "service_id: is invalid", "stack_trace: is invalid"]
      })
    end

    test "with unprocessable entity error" do
      conn = conn(:get, "/", "")

      conn =
        ErrorFallback.fallback(
          {:error, :validation_error, "invalid document"},
          conn
        )

      assert_conn(conn, 422, %{"error" => "invalid document"})
    end

    test "with not found error" do
      conn = conn(:get, "/", "")

      conn =
        ErrorFallback.fallback({:error, :not_found_error, "not found"}, conn)

      assert_conn(conn, 404, "Oops! 👀")
    end
  end
end
