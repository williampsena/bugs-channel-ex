defmodule BugsChannel.Repo.Team do
  @moduledoc """
  This module contains the database mode team repository.
  """
  @behaviour BugsChannel.Repo.Behaviours.Team

  import BugsChannel.Repo.Base
  import BugsChannel.Repo.Parsers.Team

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @collection "teams"
  @allowed_keys ~w(name)

  def get(id) do
    @collection
    |> get_by_id(id)
    |> parse(%RepoSchemas.Team{})
  end

  def list(filters, query_cursor \\ nil) when is_map(filters) do
    {results, query_cursor} = list(@collection, filters, @allowed_keys, query_cursor)

    results
    |> parse_list(%RepoSchemas.Team{})
    |> with_paged_results(query_cursor)
  end

  def insert(%RepoSchemas.Team{} = team) do
    insert(@collection, team)
  end

  def update(id, team) when is_map(team) do
    update(@collection, id, team)
  end

  def delete(id) do
    delete(@collection, id)
  end
end
