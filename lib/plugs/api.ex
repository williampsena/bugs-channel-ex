defmodule BugsChannel.Plugs.Api do
  @moduledoc """
  This module includes API supports such as response behaviors.
  """

  import Plug.Conn

  def put_json_header(%Plug.Conn{} = conn) do
    put_resp_content_type(conn, "application/json")
  end

  def send_json_resp(%Plug.Conn{} = conn, message, status \\ 200) when is_integer(status) do
    message = if is_binary(message), do: message, else: Jason.encode!(message)

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
    conn
    |> put_json_header()
    |> send_resp(422, Jason.encode!(%{"error" => message}))
  end

  def send_unknown_error_resp(%Plug.Conn{} = conn, message \\ "Something went wrong 😦") do
    send_resp(conn, 500, message)
  end

  def send_unauthorized_resp(%Plug.Conn{} = conn, message \\ "Missing credentials 🪪") do
    send_resp(conn, 401, message)
  end
end
