defmodule BugsChannel.Repo.Schemas.ServiceAuthKey do
  @moduledoc """
  The module represents a configuration service struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:key, :string, default: "")
    field(:disabled, :boolean, default: false)
    field(:expired_at, :integer, default: nil)
  end

  @doc ~S"""
  Parses map to service schema

  ## Examples

      iex> BugsChannel.Repo.Schemas.ServiceAuthKey.changeset(%BugsChannel.Repo.Schemas.ServiceAuthKey{}, %{ "key" => "key", "disabled" => true, "expired_at" => 1702552087 }).valid?
      true

      iex> BugsChannel.Repo.Schemas.ServiceAuthKey.changeset(%BugsChannel.Repo.Schemas.ServiceAuthKey{}, %{ "key" => nil, "disabled" => true, "expired_at" => nil }).valid?
      false
  """
  def changeset(%__MODULE__{} = auth_keys, params) do
    auth_keys
    |> cast(params, ~w(key disabled expired_at)a)
    |> validate_required(~w(key)a)
  end
end
