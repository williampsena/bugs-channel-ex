defmodule BugsChannel.DB.Schemas.Event do
  @moduledoc """
  The module represents a Event struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string

  schema "event" do
    field(:project_id, :integer)
    field(:meta_id, :string)
    field(:platform, :string)
    field(:environment, :string, default: "production")
    field(:release, :string)
    field(:server_name, :string)
    field(:title, :string)
    field(:body, :string)
    field(:stack_trace, {:array, :map})
    field(:kind, :string)
    field(:level, :string, default: "error")
    field(:origin, Ecto.Enum, values: [:home, :sentry], default: :home)
    field(:tags, {:array, :string})
    field(:extra_args, :map, default: %{})

    timestamps(type: :string)
  end

  @doc ~S"""
  Parses project from config file

  ## Examples

      iex> BugsChannel.DB.Schemas.Event.changeset(%BugsChannel.DB.Schemas.Event{}, %{ "id" => "abc123", "origin" => "home", "title" => "some error", "body" => "error", "project_id" => 1, "platform" => "elixir", "release" => "git-hash", "server_name" => "foo", "kind" => "error", "environment" => "production", "stack_trace" => [], "tags" => [] }).valid?
      true

      iex> BugsChannel.DB.Schemas.Event.changeset(%BugsChannel.DB.Schemas.Event{}, %{"id" => 1 }).valid?
      false
  """
  def changeset(%__MODULE__{} = event, params) do
    event
    |> cast(
      params,
      ~w(id project_id platform environment release server_name title body kind level origin stack_trace tags extra_args)a
    )
    |> validate_required(~w(level title body kind origin tags)a)
  end

  @doc ~S"""
  Parses config file

  ## Examples

      iex> BugsChannel.DB.Schemas.Event.parse(%{ "title" => "foo", "body" => "bar", "kind" => "error", "tags" => ["foo:bar"] })
      {:ok,
      %BugsChannel.DB.Schemas.Event{
        id: nil,
        project_id: nil,
        meta_id: nil,
        platform: nil,
        environment: "production",
        release: nil,
        server_name: nil,
        title: "foo",
        body: "bar",
        stack_trace: nil,
        kind: "error",
        level: "error",
        origin: :home,
        tags: ["foo:bar"],
        extra_args: %{},
        inserted_at: nil,
        updated_at: nil
      }}

      iex> {:error, changeset } = BugsChannel.DB.Schemas.Event.parse(%{ "id" => "foo" })
      iex> [changeset.valid?, changeset.errors]
      [
        false,
        [
          title: {"can't be blank", [validation: :required]},
          body: {"can't be blank", [validation: :required]},
          kind: {"can't be blank", [validation: :required]},
          tags: {"can't be blank", [validation: :required]}
        ]
      ]
  """
  def parse(params) when is_map(params) do
    %__MODULE__{} |> __MODULE__.changeset(params) |> apply_action(:update)
  end
end
