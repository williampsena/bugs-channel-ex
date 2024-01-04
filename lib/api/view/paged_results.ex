defmodule BugsChannel.Api.Views.PagedResults do
  @moduledoc """
  This view is in responsible to translate paged results to map
  """

  alias BugsChannel.Repo.Query.PagedResults
  alias BugsChannel.Utils.Maps

  @doc ~S"""
  Render PagedResults to an encodable map

  ## Examples

      iex> BugsChannel.Api.Views.PagedResults.render(%BugsChannel.Repo.Query.PagedResults{data: ["foo", "bar"],  local: %{empty: false, next_page:  %BugsChannel.Repo.Query.QueryCursor{offset: 10, limit: 10, page: 1}}, meta: %{ page: 0, offset: 0, limit: 10, count: 2 }})
      %{data: ["foo", "bar"], meta: %{ page: 0, offset: 0, limit: 10, count: 2 }}

      iex> BugsChannel.Api.Views.PagedResults.render(%BugsChannel.Repo.Query.PagedResults{data: [], local: %{empty: true}, meta: %{ page: 0, offset: 0, limit: 10, count: 0 }})
      %{data: [], meta: %{ page: 0, offset: 0, limit: 10, count: 0 }}
  """
  def render(%PagedResults{} = paged_results) do
    paged_results
    |> Map.delete(:local)
    |> Maps.map_from_struct()
  end
end
