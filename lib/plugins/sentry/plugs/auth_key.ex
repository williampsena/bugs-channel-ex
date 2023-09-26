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
    project_auth_key = feth_project_auth_key(conn)

    if is_nil(project_auth_key) do
      conn |> send_unauthorized_resp() |> halt()
    else
      assign(conn, :auth_key, project_auth_key)
    end
  end

  def feth_project_auth_key(conn) do
    sentry_auth_header = get_req_header(conn, "x-sentry-auth") |> List.first()

    if is_nil(sentry_auth_header) do
      nil
    else
      match = ~r/sentry_key=(?<value>.[^,]+)/ |> Regex.named_captures(sentry_auth_header)
      if is_nil(match), do: nil, else: match["value"]
    end
  end
end
