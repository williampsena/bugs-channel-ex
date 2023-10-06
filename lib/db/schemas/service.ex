defmodule BugsChannel.DB.Schemas.Service do
  @moduledoc """
  The module represents a configuration service struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "service" do
    field(:name, :string)
    field(:platform, :string)
    field(:team, :string, default: "bugs")
    field(:settings, :map, default: %{})
  end

  @doc ~S"""
  Parses project from config file

  ## Examples

      iex> BugsChannel.DB.Schemas.Service.changeset(%BugsChannel.DB.Schemas.Service{}, %{"id" => 1, "name" => "bar", "platform" => "python", "team" => "foo", "settings" => %{ "rate-limit" => 1, "auth-keys" => [ %{"key" => "key"}]} }).valid?
      true

      iex> BugsChannel.DB.Schemas.Service.changeset(%BugsChannel.DB.Schemas.Service{}, %{"id" => 1, "name" => "ab", "platform" => "python", "team" => "foo", "settings" => %{ "rate-limit" => 1, "auth-keys" => [ %{"key" => "key"}]} }).valid?
      false

      iex> BugsChannel.DB.Schemas.Service.changeset(%BugsChannel.DB.Schemas.Service{}, %{"id" => 1 }).valid?
      false
  """
  def changeset(%__MODULE__{} = service, params) do
    service
    |> cast(params, ~w(id name platform team settings)a)
    |> validate_required(~w(name platform team)a)
    |> validate_length(:name, min: 3)
  end
end
