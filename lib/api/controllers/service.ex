defmodule BugsChannel.Api.Controllers.Service do
  @moduledoc """
  This plug is in responsible for get and validate auth key
  """

  use BugsChannel.Api.Controllers.Controller

  import BugsChannel.Api.Models.Service

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
    with {:ok, _} <- validate(:create, params),
         do: do_create(conn, params)
  end

  defp do_create(conn, params) do
    with %Schemas.Service{} = service <- Parsers.Service.parse(params),
         {:ok, %{id: id}} <- Repo.Service.insert(service) do
      send_json_resp(conn, %{"id" => id}, 201)
    end
  end

  def update(%Plug.Conn{} = conn, %{"id" => id} = params) do
    with {:ok, updated_params} <- validate(:update, Map.put(params, "id", id)),
         :ok <- Repo.Service.update(id, updated_params) do
      send_no_content(conn)
    end
  end
end
