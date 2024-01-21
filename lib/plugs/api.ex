defmodule BugsChannel.Plugs.Api do
  @moduledoc """
  This module includes API supports such as response behaviors.
  """

  import Plug.Conn

  alias BugsChannel.Utils.Maps

  def put_json_header(%Plug.Conn{} = conn) do
    put_resp_content_type(conn, "application/json")
  end

  def send_json_resp(%Plug.Conn{} = conn, message, status \\ 200) when is_integer(status) do
    message =
      cond do
        is_binary(message) -> message
        is_struct(message) -> message |> Maps.map_from_struct() |> Jason.encode!()
        true -> Jason.encode!(message)
      end

    conn
    |> put_json_header()
    |> send_resp(status, message)
  end

  def send_not_found_resp(%Plug.Conn{} = conn, message \\ "Oops! 👀") do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, message)
  end

  def send_unprocessable_entity_resp(%Plug.Conn{} = conn, message \\ "Payload is invalid") do
    message =
      if is_binary(message),
        do: %{"error" => message},
        else: message

    send_json_resp(conn, message, 422)
  end

  def send_unknown_error_resp(%Plug.Conn{} = conn, message \\ "Something went wrong 😦") do
    if is_binary(message),
      do: send_resp(conn, 500, message),
      else: send_json_resp(conn, message, 500)
  end

  def send_unauthorized_resp(%Plug.Conn{} = conn, message \\ "Missing credentials 🪪") do
    send_resp(conn, 401, message)
  end

  def send_forbidden_resp(%Plug.Conn{} = conn, message \\ "Forbidden ⛔") do
    send_resp(conn, 403, message)
  end

  def send_too_many_requests_resp(%Plug.Conn{} = conn, limit, message \\ "Too Many Requests 😫")
      when is_integer(limit) do
    conn
    |> put_resp_header("x-rate-limit", "#{limit}")
    |> send_resp(429, message)
  end

  def send_no_content(%Plug.Conn{} = conn) do
    send_resp(conn, 204, "")
  end
end
