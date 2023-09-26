defmodule BugsChannel.Plugins.Sentry.Router do
  use Plug.Router
  use Plug.ErrorHandler

  import BugsChannel.Utils.Config
  import BugsChannel.Plugs.Api

  alias BugsChannel.Plugins.Sentry.Utils.EnvelopeParser, as: SentryEnvelopeParser
  alias BugsChannel.Plugins.Sentry.Plugs.AuthKey, as: SentryAuthKey

  require Logger

  if development?(), do: plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(SentryAuthKey)

  plug(Plug.Parsers,
    parsers: [SentryEnvelopeParser],
    pass: ["application/x-sentry-envelope"],
    json_decoder: Jason
  )

  plug(:dispatch)

  forward("/api/:project/envelope", to: BugsChannel.Plugins.Sentry.Plugs.Event)

  match(_, do: send_not_found_resp(conn))

  defp handle_errors(conn, error) do
    Logger.error("UnknownSentryPlugRouteError: #{inspect(error)}")
    send_unknown_error_resp(conn)
  end
end
