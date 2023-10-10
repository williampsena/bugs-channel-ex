defmodule BugsChannel.Repo.Schemas.ServiceAuthKeys do
  @moduledoc """
  The module represents a configuration service struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "service_auth_keys" do
    field(:key, :string, default: "")
    field(:disabled, :boolean, default: false)
    field(:expired_at, :date, default: nil)
  end

  @doc ~S"""
  Parses map to service schema

  ## Examples

      iex> BugsChannel.Repo.Schemas.ServiceAuthKeys.changeset(%BugsChannel.Repo.Schemas.ServiceAuthKeys{}, %{ "key" => "key", "disabled" => true, "expired_at" => nil }).valid?
      true

      iex> BugsChannel.Repo.Schemas.ServiceAuthKeys.changeset(%BugsChannel.Repo.Schemas.ServiceAuthKeys{}, %{ "key" => nil, "disabled" => true, "expired_at" => nil }).valid?
      false
  """
  def changeset(%__MODULE__{} = auth_keys, params) do
    auth_keys
    |> cast(params, ~w(key disabled expired_at)a)
    |> validate_required(~w(key)a)
  end
end
