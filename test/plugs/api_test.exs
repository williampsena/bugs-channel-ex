defmodule BugsChannel.Plugs.ApiTest do
  use ExUnit.Case
  use Plug.Test

  import BugsChannel.Test.Support.ApiHelper

  alias BugsChannel.Plugs.Api

  describe "put_json_header/1" do
    test "with default message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.put_json_header()

      assert {"content-type", "application/json; charset=utf-8"} in conn.resp_headers
    end
  end

  describe "send_json_resp" do
    test "with default status code" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_json_resp("string")

      assert_conn(conn, 200, "string")
    end

    test "with custom status code" do
      body = %{"message" => "ok"}

      conn =
        :get
        |> conn("/", "")
        |> Api.send_json_resp(body, 202)

      assert_conn(conn, 202, Jason.encode!(body))
    end
  end

  describe "send_not_found_resp" do
    test "with default message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_not_found_resp()

      assert_conn(conn, 404, "Oops! 👀")
    end

    test "with custom message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_not_found_resp("Not found")

      assert_conn(conn, 404, "Not found")
    end
  end

  describe "send_unprocessable_entity_resp" do
    test "with default message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_unprocessable_entity_resp()

      assert_conn(conn, 422, Jason.encode!(%{"error" => "Payload is invalid"}))
    end

    test "with custom message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_unprocessable_entity_resp("Invalid payload")

      assert_conn(conn, 422, Jason.encode!(%{"error" => "Invalid payload"}))
    end
  end

  describe "send_unknown_error_resp" do
    test "with default message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_unknown_error_resp()

      assert_conn(conn, 500, "Something went wrong 😦")
    end

    test "with custom message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_unknown_error_resp("Too bad!")

      assert_conn(conn, 500, "Too bad!")
    end
  end

  describe "send_unauthorized_resp" do
    test "with default message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_unauthorized_resp()

      assert_conn(conn, 401, "Missing credentials 🪪")
    end

    test "with custom message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_unauthorized_resp("Stop ✋!")

      assert_conn(conn, 401, "Stop ✋!")
    end
  end

  describe "send_too_many_requests_resp" do
    test "with default message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_too_many_requests_resp(1)

      assert_conn(conn, 429, "Too Many Requests 😫")
      assert {"x-rate-limit", "1"} in conn.resp_headers
    end

    test "with custom message" do
      conn =
        :get
        |> conn("/", "")
        |> Api.send_too_many_requests_resp(100, "Hold on ✋!")

      assert_conn(conn, 429, "Hold on ✋!")
      assert {"x-rate-limit", "100"} in conn.resp_headers
    end
  end
end
