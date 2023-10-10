defmodule BugsChannel.Services.Fetcher do
  @moduledoc """
  This module is in charge of retrieving and querying the Services entity using cache.
  """

  use Nebulex.Caching

  alias BugsChannel.Cache
  alias BugsChannel.Repo.Schemas

  @ttl :timer.hours(1)

  @decorate cacheable(cache: Cache.module(), key: {Schemas.Service, id}, opts: [ttl: @ttl])
  def get(id) do
    repo().get(id)
  end

  @decorate cacheable(
              cache: Cache.module(),
              key: {Schemas.Service, "auth_key", auth_key},
              opts: [ttl: @ttl]
            )
  @spec get_by_auth_key(String.t()) :: Schemas.Service | nil
  def get_by_auth_key(auth_key) do
    repo().get_by_auth_key(auth_key)
  end

  @spec repo :: any
  defp repo(), do: Application.get_env(:bugs_channel, :repos)[:service]
end
