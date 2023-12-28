defmodule BugsChannel.Repo.Query.QueryCursor do
  @moduledoc """
  The module represents a query cursor struct.
  """

  defstruct ~w(page offset limit)a

  @doc ~S"""
  Build an query cursor schema

  ## Examples

      iex> BugsChannel.Repo.Query.QueryCursor.build(0)
      %BugsChannel.Repo.Query.QueryCursor{page: 0, offset: 0, limit: 25}

      iex> BugsChannel.Repo.Query.QueryCursor.build(0, 10)
      %BugsChannel.Repo.Query.QueryCursor{page: 0, offset: 0, limit: 10}

      iex> BugsChannel.Repo.Query.QueryCursor.build(1, 10)
      %BugsChannel.Repo.Query.QueryCursor{page: 1, offset: 10, limit: 10}

      iex> BugsChannel.Repo.Query.QueryCursor.build(2, 10)
      %BugsChannel.Repo.Query.QueryCursor{page: 2, offset: 20, limit: 10}

      iex> BugsChannel.Repo.Query.QueryCursor.build_next(%BugsChannel.Repo.Query.QueryCursor{page: 2, offset: 20, limit: 10})
      %BugsChannel.Repo.Query.QueryCursor{page: 3, offset: 30, limit: 10}

      iex> BugsChannel.Repo.Query.QueryCursor.build_next_url(%BugsChannel.Repo.Query.QueryCursor{page: 1, offset: 20, limit: 10}, "/foo", %{"bar" => "foo"})
      "/foo?index=2&limit=10&bar=foo"

  """
  def build(index), do: build(index, query_results_per_page())

  def build(index, per_page) when is_integer(index) and is_integer(per_page) do
    offset = calc_offset(index, per_page)

    %__MODULE__{page: index, offset: offset, limit: per_page}
  end

  def build_next(%__MODULE__{} = query_cursor) do
    build(query_cursor.page + 1, query_cursor.limit)
  end

  def build_next_url(%__MODULE__{} = query_cursor, uri_path, query_params) do
    next_query_cursor = build_next(query_cursor)

    query_string =
      query_params
      |> Map.merge(%{
        index: next_query_cursor.page,
        limit: next_query_cursor.limit
      })
      |> URI.encode_query()

    "#{uri_path}?#{query_string}"
  end

  defp calc_offset(index, per_page) do
    index * per_page
  end

  defp query_results_per_page, do: config()[:query_results_per_page]
  defp config, do: Application.get_env(:bugs_channel, :query)
end
