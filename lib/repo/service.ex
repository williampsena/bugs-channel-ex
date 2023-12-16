defmodule BugsChannel.Repo.Service do
  @moduledoc """
  This module contains the database mode service repository.
  """
  import BugsChannel.Repo.Parsers.Service

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @collection "services"

  @spec get(String.t()) :: RepoSchemas.Service
  def get(id) do
    :mongo
    |> Mongo.find_one(@collection, %{_id: BSON.ObjectId.decode!(id)})
    |> parse(%RepoSchemas.Service{})
  end

  @spec get_by_auth_key(String.t()) :: RepoSchemas.Service
  def get_by_auth_key(auth_key) do
    :mongo
    |> Mongo.find_one(@collection, %{"auth_keys.key": auth_key})
    |> parse(%RepoSchemas.Service{})
  end
end
