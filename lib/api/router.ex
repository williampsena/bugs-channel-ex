defmodule BugsChannel.Api.Router do
  use Plug.Router
  use Plug.ErrorHandler
  use BugsChannel.Api.RouterHandler

  alias BugsChannel.Api.Controllers
  #alias BugsChannel.Repo.Parsers

  import BugsChannel.Utils.Config
  import BugsChannel.Plugs.Api

  require Logger

  if development?(), do: use(Plug.Debugger)

  plug(Corsica, origins: "*")

  plug(:match)

  plug(Plug.Parsers, parsers: [:urlencoded, :multipart, :json], json_decoder: Jason)

  if development?(), do: plug(Plug.Logger, log: :debug)

  plug(:dispatch)

  get("/health_check", do: controller(conn, Controllers.HealthCheck, :index))

  if BugsChannel.mongo_as_target?() || test?() do
    get("/services", do: controller(conn, Controllers.Service, :index, conn.params))
    get("/services/:id", do: controller(conn, Controllers.Service, :show, %{"id" => id}))

    post("/services",
      do: controller(conn, Controllers.Service, :create, conn.params)
    )
  end

  match(_, do: send_not_found_resp(conn))

  def handle_errors(conn, error) do
    Logger.error("UnknownPlugRouteError #{inspect(error)}")
    send_unknown_error_resp(conn)
  end
end
