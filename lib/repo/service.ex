defmodule BugsChannel.Repo.Service do
  @moduledoc """
  This module contains the database mode service repository.
  """
  @behaviour BugsChannel.Repo.Behaviours.Service

  import BugsChannel.Repo.Base
  import BugsChannel.Repo.Parsers.Service

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @collection "services"
  @allowed_keys ~w(name platform)

  def get(id) do
    @collection
    |> get_by_id(id)
    |> parse(%RepoSchemas.Service{})
  end

  def get_by_auth_key(auth_key) do
    @collection
    |> find_one(%{"auth_keys.key" => auth_key})
    |> parse(%RepoSchemas.Service{})
  end

  def insert(%RepoSchemas.Service{} = service) do
    insert(@collection, service)
  end

  def list(filters, query_cursor \\ nil) when is_map(filters) do
    filters = Map.take(filters, @allowed_keys)

    {query_cursor, query_opts} = build_query_options([], query_cursor)

    @collection
    |> find(filters, query_opts)
    |> parse_list(%RepoSchemas.Service{})
    |> with_paged_results(query_cursor)
  end
end
