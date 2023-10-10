defmodule BugsChannel.Repo.Schemas.ServiceSettings do
  @moduledoc """
  The module represents a configuration service struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "service_settings" do
    field(:rate_limit, :integer, default: 0)
  end

  @doc ~S"""
  Parses map to service schema

  ## Examples

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => 1, "name" => "bar", "platform" => "python", "team" => "foo", "settings" => %{ "rate_limit" => 1 }, "auth_keys" => [ %{"key" => "key"} ] }).valid?
      true

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => 1, "name" => "ab", "platform" => "python", "team" => "foo", "settings" => %{ "rate_limit" => 1 }, "auth_keys" => [ %{"key" => "key"} ] }).valid?
      false

      iex> BugsChannel.Repo.Schemas.Service.changeset(%BugsChannel.Repo.Schemas.Service{}, %{"id" => 1 }).valid?
      false
  """
  def changeset(%__MODULE__{} = service, params) do
    service
    |> cast(params, ~w(rate_limit)a)
    |> validate_number(:rate_limit, greater_than: -1)
  end
end
