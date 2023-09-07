defmodule BugsChannel.Router do
  use Plug.Router
  use Plug.ErrorHandler

  require Logger

  plug(Plug.Parsers, parsers: [:urlencoded, :multipart])
  plug(:match)
  plug(:dispatch)

  forward("/health_check", to: BugsChannel.Plugs.HealthCheck)

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Oops! 👀")
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    Logger.error("UnknownPlugRouteError #{kind}, #{reason} #{inspect(stack)}")
    send_resp(conn, conn.status, "Something went wrong")
  end
end
