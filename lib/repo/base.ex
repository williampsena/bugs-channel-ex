defmodule BugsChannel.Repo.Base do
  @moduledoc """
  This module contains the database base repository.
  """
  use BugsChannel.Repo.Parsers.Base

  @behaviour BugsChannel.Repo.Behaviours.Base

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
  def find(collection, query) do
    with %Mongo.Stream{docs: docs} <- Mongo.find(:mongo, collection, query) do
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
end
