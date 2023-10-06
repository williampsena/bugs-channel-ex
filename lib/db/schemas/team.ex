defmodule BugsChannel.DB.Schemas.Team do
  @moduledoc """
  The module represents a configuration team struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "team" do
    field(:name, :string)
  end

  @doc ~S"""
  Parses team from config file

  ## Examples

      iex> BugsChannel.DB.Schemas.Team.changeset(%BugsChannel.DB.Schemas.Team{}, %{"id" => 1, "name" => "foo" }).valid?
      true

      iex> BugsChannel.DB.Schemas.Team.changeset(%BugsChannel.DB.Schemas.Team{}, %{ "id" => "foo" }).valid?
      false
  """
  def changeset(%__MODULE__{} = team, params) do
    team
    |> cast(params, ~w(id name)a)
    |> validate_required(~w(name)a)
    |> validate_length(:name, min: 3)
  end
end
