defmodule BugsChannel.Api.Controllers.Service do
  @moduledoc """
  This plug is in responsible for get and validate auth key
  """

  use BugsChannel.Api.Controllers.Controller

  alias BugsChannel.Repo.Service

  def index(%Plug.Conn{} = conn, filters) do
    paged_results = Service.list(filters)
    send_json_resp(conn, render(paged_results))
  end

  def show(%Plug.Conn{} = conn, %{"id" => id}) do
    case Service.get(id) do
      nil -> send_not_found_resp(conn)
      service -> send_json_resp(conn, service)
    end
  end
end
