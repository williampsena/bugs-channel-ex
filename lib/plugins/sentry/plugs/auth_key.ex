defmodule BugsChannel.Plugins.Sentry.Plugs.AuthKey do
  @moduledoc """
  This plug is in responsible for get and validate sentry auth key
  """

  require Logger

  import Plug.Conn
  import BugsChannel.Plugs.Api

  def init(options) do
    options
  end

  def call(conn, _opts) do
    service_auth_key = fetch_service_auth_key(conn)

    if is_nil(service_auth_key) do
      conn |> send_unauthorized_resp() |> halt()
    else
      assign(conn, :auth_key, service_auth_key)
    end
  end

  defp fetch_service_auth_key(conn) do
    sentry_auth_header = get_req_header(conn, "x-sentry-auth") |> List.first()

    if is_binary(sentry_auth_header) do
      match = ~r/sentry_key=(?<value>.+?),/ |> Regex.named_captures(sentry_auth_header)
      if is_map(match), do: match["value"]
    else
      fetch_service_auth_key_from_query(conn)
    end
  end

  defp fetch_service_auth_key_from_query(conn) do
    conn_parsed = fetch_query_params(conn)
    conn_parsed.query_params["sentry_key"]
  end
end
