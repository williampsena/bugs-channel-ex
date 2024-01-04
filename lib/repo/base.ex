defmodule BugsChannel.Repo.Base do
  @moduledoc """
  This module contains the database base repository.
  """
  use BugsChannel.Repo.Parsers.Base
  alias BugsChannel.Repo.Query.{PagedResults, QueryCursor}

  @behaviour BugsChannel.Repo.Behaviours.Base

  @default_query_cursor QueryCursor.build(0)

  @doc """
  Select one document in a collection by id.
  """
  def get_by_id(collection, id) do
    find_one(collection, %{_id: BSON.ObjectId.decode!(id)})
  end

  @doc """
  Select one document in a collection.
  """
  def find_one(collection, query) do
    Mongo.find_one(:mongo, collection, query)
  end

  @doc """
  Selects documents in a collection.
  """
  def find(collection, query, opts \\ []) do
    with %Mongo.Stream{docs: docs} <- Mongo.find(:mongo, collection, query, opts) do
      docs
    end
  end

  @doc """
  Insert documents in a collection.
  """
  def insert(collection, struct) do
    with {:ok, %Mongo.InsertOneResult{inserted_id: id}} <-
           Mongo.insert_one(:mongo, collection, parse_to_document(struct, :insert)) do
      {:ok, Map.put(struct, :id, "#{id}")}
    end
  end

  @doc """
  Build mongo query options such as pagination parameters
  Build an query cursor schema

  ## Examples

      iex> BugsChannel.Repo.Base.build_query_options([], %BugsChannel.Repo.Query.QueryCursor{page: 0, offset: 0, limit: 20})
      {%BugsChannel.Repo.Query.QueryCursor{page: 0, offset: 0, limit: 20}, [skip: 0, limit: 20]}

      iex> BugsChannel.Repo.Base.build_query_options([], nil)
      {%BugsChannel.Repo.Query.QueryCursor{page: 0, offset: 0, limit: 25}, [skip: 0, limit: 25]}

  """
  def build_query_options(opts, nil),
    do: build_query_options(opts, @default_query_cursor)

  def build_query_options(opts, %QueryCursor{} = query_cursor) do
    {query_cursor,
     Keyword.merge(opts,
       skip: query_cursor.offset,
       limit: query_cursor.limit
     )}
  end

  @doc """
  Build mongo query options such as pagination parameters

  ## Examples

      iex> BugsChannel.Repo.Base.with_paged_results([], %BugsChannel.Repo.Query.QueryCursor{page: 0, offset: 0, limit: 25})
      %BugsChannel.Repo.Query.PagedResults{data: [], meta: %{count: 0, offset: 0, limit: 25, page: 0}, local: %{empty: true}}

  """
  def with_paged_results(results, %QueryCursor{} = query_cursor) when is_list(results) do
    PagedResults.build(results, query_cursor)
  end
end
