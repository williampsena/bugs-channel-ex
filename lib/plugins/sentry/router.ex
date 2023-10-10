defmodule BugsChannel.Plugins.Sentry.Router do
  use Plug.Router
  use Plug.ErrorHandler

  import BugsChannel.Utils.Config
  import BugsChannel.Plugs.Api

  alias BugsChannel.Plugs.RateLimiter, as: RateLimiterPlug
  alias BugsChannel.Plugs.CheckAuthKey, as: CheckAuthKeyPlug
  alias BugsChannel.Plugins.Sentry.Utils.EnvelopeParser, as: SentryEnvelopeParser
  alias BugsChannel.Plugins.Sentry.Plugs.AuthKey, as: SentryAuthKeyPlug

  require Logger

  if development?(), do: plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(SentryAuthKeyPlug)
  plug(CheckAuthKeyPlug)

  plug(RateLimiterPlug, key: "event", by: [:assigns, :auth_key])

  plug(Plug.Parsers,
    parsers: [SentryEnvelopeParser],
    pass: ["application/x-sentry-envelope"],
    json_decoder: Jason
  )

  plug(:dispatch)

  forward("/api/:project/envelope", to: BugsChannel.Plugins.Sentry.Plugs.Event)

  match(_, do: send_not_found_resp(conn))

  def handle_errors(conn, error) do
    Logger.error("UnknownSentryPlugRouteError: #{inspect(error)}")
    send_unknown_error_resp(conn)
  end
end
