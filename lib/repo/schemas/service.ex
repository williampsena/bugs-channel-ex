defmodule BugsChannel.Repo.Schemas.Service do
  @moduledoc """
  The module represents a configuration service struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @primary_key {:id, :string, autogenerate: false}

  schema "service" do
    field(:name, :string)
    field(:platform, :string)
    embeds_many(:teams, RepoSchemas.Team)
    embeds_one(:settings, RepoSchemas.ServiceSettings)
    embeds_many(:auth_keys, RepoSchemas.ServiceAuthKey)
  end

  @doc ~S"""
  Parses map to service schema

  ## Examples

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => "1", "name" => "bar", "platform" => "python", "teams" => [ %{  "id" => "1", "name" => "foo" } ], "settings" => %{ "rate_limit" => 1, "auth_keys" => [ %{"key" => "key"}]} }).valid?
      true

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => "1", "name" => "ab", "platform" => "python", "teams" => "foo", "settings" => %{ "rate_limit" => 1, "auth_keys" => [ %{"key" => "key"}]} }).valid?
      false

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => "1" }).valid?
      false
  """
  def changeset(%__MODULE__{} = service, params) do
    service
    |> cast(params, ~w(id name platform)a)
    |> cast_embed(:settings)
    |> cast_embed(:auth_keys)
    |> cast_embed(:teams, require: true)
    |> validate_required(~w(name platform)a)
    |> validate_length(:name, min: 3)
  end
end
