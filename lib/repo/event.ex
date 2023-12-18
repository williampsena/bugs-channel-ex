defmodule BugsChannel.Repo.Event do
  @moduledoc """
  This module contains the database mode event repository.
  """
  @behaviour BugsChannel.Repo.Behaviours.Event

  import BugsChannel.Repo.Base
  import BugsChannel.Repo.Parsers.Event

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @collection "events"

  def get(id) do
    @collection
    |> get_by_id(id)
    |> parse(%RepoSchemas.Event{})
  end

  def list(service_id) do
    @collection
    |> find(%{"service_id" => service_id})
    |> parse_list(%RepoSchemas.Event{})
  end

  def insert(%RepoSchemas.Event{} = event) do
    insert(@collection, event)
  end
end
