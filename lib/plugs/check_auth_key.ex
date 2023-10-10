defmodule BugsChannel.Plugs.CheckAuthKey do
  @moduledoc """
  This plug is in responsible for get and validate auth key
  """

  require Logger

  import Plug.Conn
  import BugsChannel.Plugs.Api

  alias BugsChannel.Services.Fetcher

  def init(options) do
    options
  end

  def call(conn, _opts) do
    auth_key = fetch_auth_key(conn)

    if is_binary(auth_key) and auth_key != "" do
      do_check_auth_key(conn, auth_key)
    else
      halt_connection(conn)
    end
  end

  defp halt_connection(conn) do
    conn |> send_unauthorized_resp() |> halt()
  end

  defp do_check_auth_key(conn, auth_key) do
    service = Fetcher.get_by_auth_key(auth_key)

    if is_nil(service) do
      halt_connection(conn)
    else
      assign(conn, :service, service)
      assign(conn, :auth_key, auth_key)
    end
  end

  defp fetch_auth_key(conn) do
    if is_binary(conn.assigns[:auth_key]) do
      conn.assigns[:auth_key]
    else
      fetch_from_headers(conn)
    end
  end

  defp fetch_from_headers(conn) do
    get_req_header(conn, "x-auth-key") |> List.first()
  end
end
