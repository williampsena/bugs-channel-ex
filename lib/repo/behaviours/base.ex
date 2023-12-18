defmodule BugsChannel.Repo.Behaviours.Base do
  @moduledoc """
  This module contains base behaviors.
  """

  @callback get_by_id(collection :: String.t(), id :: String.t()) ::
              BSON.document() | nil | {:error, any}

  @callback find_one(collection :: String.t(), query :: map()) ::
              BSON.document() | nil | {:error, any}

  @callback find(collection :: String.t(), query :: map()) ::
              list(BSON.document()) | nil | {:error, any}

  @callback insert(collection :: String.t(), struct :: struct()) ::
              {:ok, Mongo.InsertOneResult.t()} | nil | {:error, any}
end
