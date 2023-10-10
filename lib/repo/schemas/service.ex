defmodule BugsChannel.Repo.Schemas.Service do
  @moduledoc """
  The module represents a configuration service struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  schema "service" do
    field(:name, :string)
    field(:platform, :string)
    field(:team, :string, default: "bugs")
    embeds_one(:settings, RepoSchemas.ServiceSettings)
    embeds_many(:auth_keys, RepoSchemas.ServiceAuthKeys)
  end

  @doc ~S"""
  Parses map to service schema

  ## Examples

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => 1, "name" => "bar", "platform" => "python", "team" => "foo", "settings" => %{ "rate_limit" => 1, "auth-keys" => [ %{"key" => "key"}]} }).valid?
      true

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => 1, "name" => "ab", "platform" => "python", "team" => "foo", "settings" => %{ "rate_limit" => 1, "auth-keys" => [ %{"key" => "key"}]} }).valid?
      false

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => 1 }).valid?
      false
  """
  def changeset(%__MODULE__{} = service, params) do
    service
    |> cast(params, ~w(id name platform team)a)
    |> cast_embed(:settings)
    |> cast_embed(:auth_keys)
    |> validate_required(~w(name platform team)a)
    |> validate_length(:name, min: 3)
  end
end
