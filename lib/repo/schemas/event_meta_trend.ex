defmodule BugsChannel.Repo.Schemas.EventMetaTrend do
  @moduledoc """
  The module represents a Event meta trend struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(hour count avg min max)a

  embedded_schema do
    field(:hour, :integer)
    field(:count, :integer)
    field(:avg, :integer)
    field(:min, :integer)
    field(:max, :integer)
  end

  @doc ~S"""
  Parses map to event meta trend

  ## Examples

      iex> BugsChannel.Repo.Schemas.EventMetaTrend.changeset(%BugsChannel.Repo.Schemas.EventMetaTrend{}, %{ "hour" => 0, "count" => 10, "avg" => 4, "max" => 8, "min" => 2 }).valid?
      true

      iex> BugsChannel.Repo.Schemas.EventMetaTrend.changeset(%BugsChannel.Repo.Schemas.EventMetaTrend{}, %{"id" => 1 }).valid?
      false
  """
  def changeset(%__MODULE__{} = trend, params) do
    trend
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_inclusion(:hour, 0..23)
  end

  @doc ~S"""
  Parses config file

  ## Examples

      iex> BugsChannel.Repo.Schemas.EventMetaTrend.parse(%{ "hour" => 0, "count" => 10, "avg" => 4, "max" => 8, "min" => 2 })
      {:ok,
      %BugsChannel.Repo.Schemas.EventMetaTrend{
        id: nil,
        hour: 0,
        count: 10,
        avg: 4,
        min: 2,
        max: 8
      }}

      iex> {:error, changeset } = BugsChannel.Repo.Schemas.EventMetaTrend.parse(%{ "id" => "foo" })
      iex> [changeset.valid?, changeset.errors]
      [
        false,
        [
          hour: {"can't be blank",  [validation: :required]},
          count: {"can't be blank", [validation: :required]},
          avg: {"can't be blank", [validation: :required]},
          min: {"can't be blank", [validation: :required]},
          max: {"can't be blank", [validation: :required]},
        ]
      ]
  """
  def parse(params) when is_map(params) do
    %__MODULE__{} |> __MODULE__.changeset(params) |> apply_action(:update)
  end
end
