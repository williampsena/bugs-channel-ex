defmodule BugsChannel.Api.Models.Service do
  @moduledoc """
  This model is responsible for validating request bodies for the Service API.
  """
  use Goal

  defparams :create do
    required(:name, :string, min: 3, max: 100)
    required(:platform, :string, min: 3, max: 100)
    optional(:teams, {:array, :string})
  end

  defparams :update do
    required(:id, :string)
    optional(:name, :string, min: 3, max: 100)
    optional(:platform, :string, min: 3, max: 100)
    optional(:teams, {:array, :string})
  end
end
