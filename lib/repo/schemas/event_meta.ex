defmodule BugsChannel.Repo.Schemas.EventMeta do
  @moduledoc """
  The module represents a Event struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string

  schema "event_meta" do
    field(:key, :string)
    field(:description, :string)
    field(:platform, :string)
    field(:level, :string, default: "error")
    field(:environment, :string, default: "production")
    field(:count, :integer, default: 1)
    field(:tags, {:array, :string})

    embeds_many(:trends, RepoSchemas.EventMetaTrend)

    timestamps(type: :string)
  end

  @doc ~S"""
  Parses map to event meta schema

  ## Examples

      iex> BugsChannel.Repo.Schemas.EventMeta.changeset(%BugsChannel.Repo.Schemas.EventMeta{}, %{ "key" => "hash-foo-bar", "description" => "unknown error", "platform" => "elixir", "level" => "error", "environment" => "test", "count" => 1, "tags" => ["foo:bar"] }).valid?
      true

      iex> BugsChannel.Repo.Schemas.EventMeta.changeset(%BugsChannel.Repo.Schemas.EventMeta{}, %{"id" => 1 }).valid?
      false
  """
  def changeset(%__MODULE__{} = event_meta, params) do
    event_meta
    |> cast(
      params,
      ~w(key description level environment platform count tags)a
    )
    |> cast_embed(:trends, require: false)
    |> validate_required(~w(key description platform)a)
  end

  @doc ~S"""
  Parses config file

  ## Examples

      iex> BugsChannel.Repo.Schemas.EventMeta.parse(%{ "key" => "hash-foo-bar", "description" => "unknown error", "platform" => "elixir", "level" => "error", "environment" => "test", "count" => 1, "tags" => ["foo:bar"] })
      {:ok,
      %BugsChannel.Repo.Schemas.EventMeta{
        count: 1,
        description: "unknown error",
        environment: "test",
        id: nil,
        inserted_at: nil,
        key: "hash-foo-bar",
        level: "error",
        platform: "elixir",
        tags: ["foo:bar"],
        trends: [],
        updated_at: nil
      }}

      iex> {:error, changeset } = BugsChannel.Repo.Schemas.EventMeta.parse(%{ "id" => "foo" })
      iex> [changeset.valid?, changeset.errors]
      [
        false,
        [
          key: {
            "can't be blank",
            [
              validation: :required
            ]
          },
          description: {
            "can't be blank",
            [
              validation: :required
            ]
          },
          platform: {
            "can't be blank",
            [
              validation: :required
            ]
          }
        ]
      ]
  """
  def parse(params) when is_map(params) do
    %__MODULE__{} |> __MODULE__.changeset(params) |> apply_action(:update)
  end
end
