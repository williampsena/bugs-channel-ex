defmodule BugsChannel.Api.Controllers.Service do
  @moduledoc """
  This plug is in responsible for get and validate auth key
  """

  use BugsChannel.Api.Controllers.Controller

  alias BugsChannel.{Repo, Repo.Schemas, Repo.Parsers}

  def index(%Plug.Conn{} = conn, filters) do
    paged_results = Repo.Service.list(filters)
    send_json_resp(conn, render(paged_results))
  end

  def show(%Plug.Conn{} = conn, %{"id" => id}) do
    case Repo.Service.get(id) do
      nil -> send_not_found_resp(conn)
      %Schemas.Service{} = service -> send_json_resp(conn, service)
    end
  end

  def create(%Plug.Conn{} = conn, params) do
    case Parsers.Service.parse(params) do
      {:error, changeset} ->
        send_unprocessable_entity_resp(conn, render_ecto_error(changeset))

      %Schemas.Service{} = service ->
        do_create(conn, service)
    end
  end

  defp do_create(%Plug.Conn{} = conn, %Schemas.Service{} = service) do
    with {:ok, _} <- Repo.Service.insert(service) do
      send_no_content(conn)
    end
  end
end
