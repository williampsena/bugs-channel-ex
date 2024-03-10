defmodule BugsChannel.Repo.Parsers.Team do
  @moduledoc """
  This module includes database document parsers or mappers for the Team entity.
  """

  use BugsChannel.Repo.Parsers.Base

  alias BugsChannel.Utils.Maps
  alias BugsChannel.Utils.Ecto, as: EctoUtils
  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @doc ~S"""
  Validate a map as Team schema.

  ## Examples

      iex> changeset = BugsChannel.Repo.Parsers.Team.validate(nil)
      iex> {changeset.valid?, changeset.errors}
      {false, [name: {"can't be blank", [validation: :required]}]}

      iex> BugsChannel.Repo.Parsers.Team.validate(%{}).valid?
      false

      iex> BugsChannel.Repo.Parsers.Team.validate(%{"id" => "1", "name" => "bar", "platform" => "python", "teams" => [ %{  "id" => "1", "name" => "foo" } ], "settings" => %{ "rate_limit" => 1, "auth_keys" => [ %{"key" => "key"}]} }).valid?
      true

  """
  def validate(doc), do: EctoUtils.validate_document(%RepoSchemas.Team{}, doc)

  @doc ~S"""
  Parse a map to Team schemas.

  ## Examples

      iex> BugsChannel.Repo.Parsers.Team.parse(nil)
      nil

      iex> BugsChannel.Repo.Parsers.Team.parse(nil, %{})
      nil

      iex> BugsChannel.Repo.Parsers.Team.parse(%{}, nil)
      {:error, :invalid_schema}

      iex> BugsChannel.Repo.Parsers.Team.parse(%{"id" => "1", "name" => "bar" }, %BugsChannel.Repo.Schemas.Team{})
      %BugsChannel.Repo.Schemas.Team{
        id: "1",
        name: "bar",
      }
  """
  def parse(doc), do: parse(doc, %RepoSchemas.Team{})

  def parse(nil, _schema), do: nil

  def parse(doc, %RepoSchemas.Team{} = schema) do
    params = parse_team(doc)

    EctoUtils.parse_document(schema, params)
  end

  def parse(_doc, _schema), do: invalid_schema_error()

  defp parse_team(doc) when is_map(doc) do
    %{
      id: "#{doc["_id"] || doc["id"]}",
      name: doc["name"]
    }
  end

  defp parse_team(_doc), do: invalid_schema_error()

  @doc ~S"""
  Parse a document list to schemas.

  ## Examples
      iex> BugsChannel.Repo.Parsers.Team.parse_list([%{ "id" => "1", "name" => "bar" }], %BugsChannel.Repo.Schemas.Team{})
      [%BugsChannel.Repo.Schemas.Team{id: "1", name: "bar"}]

      iex> BugsChannel.Repo.Parsers.Team.parse_list([1], %BugsChannel.Repo.Schemas.Team{})
      [{:error, :empty_document}]
  """
  def parse_list(docs, schema) when is_list(docs) and is_struct(schema) do
    Enum.map(docs, fn doc -> __MODULE__.parse(doc, schema) end)
  end
end
