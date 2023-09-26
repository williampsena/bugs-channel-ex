defmodule BugsChannel.Router do
  use Plug.Router
  use Plug.ErrorHandler

  import BugsChannel.Utils.Config
  import BugsChannel.Plugs.Api

  require Logger

  if development?(), do: use(Plug.Debugger)

  plug(:match)

  plug(Plug.Parsers, parsers: [:urlencoded, :multipart])

  if development?(), do: plug(Plug.Logger, log: :debug)

  plug(:dispatch)

  forward("/health_check", to: BugsChannel.Plugs.HealthCheck)

  match(_, do: send_not_found_resp(conn))

  defp handle_errors(conn, error) do
    Logger.error("UnknownPlugRouteError #{inspect(error)}")
    send_unknown_error_resp(conn)
  end
end
