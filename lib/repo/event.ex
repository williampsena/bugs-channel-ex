defmodule BugsChannel.Repo.Event do
  @moduledoc """
  This module contains the database mode event repository.
  """
  @behaviour BugsChannel.Repo.Behaviours.Event

  import BugsChannel.Repo.Base
  import BugsChannel.Repo.Parsers.Event

  alias BugsChannel.Repo.Schemas, as: RepoSchemas
  alias BugsChannel.Repo.Query.QueryCursor

  @collection "events"
  @default_query_cursor QueryCursor.build(0)

  def get(id) do
    @collection
    |> get_by_id(id)
    |> parse(%RepoSchemas.Event{})
  end

  def list_by_service(service_id, query_cursor \\ nil) when is_binary(service_id) do
    list(%{"service_id" => service_id}, query_cursor)
  end

  def list(filters, query_cursor \\ nil) when is_map(filters) do
    query_cursor = query_cursor || @default_query_cursor
    query_opts = build_query_options([], query_cursor)

    @collection
    |> find(filters, query_opts)
    |> parse_list(%RepoSchemas.Event{})
    |> with_paged_results(query_cursor)
  end

  def insert(%RepoSchemas.Event{} = event) do
    insert(@collection, event)
  end
end
