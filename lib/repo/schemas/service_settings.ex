defmodule BugsChannel.Repo.Schemas.ServiceSettings do
  @moduledoc """
  The module represents a configuration service struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:rate_limit, :integer, default: 0)
  end

  @doc ~S"""
  Parses map to service settings schema

  ## Examples

      iex> BugsChannel.Repo.Schemas.ServiceSettings.changeset(%BugsChannel.Repo.Schemas.ServiceSettings{}, %{ "rate_limit" => 1 }).valid?
      true

      iex> BugsChannel.Repo.Schemas.ServiceSettings.changeset(%BugsChannel.Repo.Schemas.ServiceSettings{}, %{ "rate_limit" => -1 }).valid?
      false
  """
  def changeset(%__MODULE__{} = service, params) do
    service
    |> cast(params, ~w(rate_limit)a)
    |> validate_number(:rate_limit, greater_than: -1)
  end
end
