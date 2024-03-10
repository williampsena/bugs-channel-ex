defmodule BugsChannel.Repo.Parsers.Service do
  @moduledoc """
  This module includes database document parsers or mappers for the Service entity.
  """

  use BugsChannel.Repo.Parsers.Base

  alias BugsChannel.Utils.Maps
  alias BugsChannel.Utils.Ecto, as: EctoUtils
  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @doc ~S"""
  Validate a map as Service, ServiceSettings, ServiceAuthKey, and Teams schemas.

  ## Examples

      iex> changeset = BugsChannel.Repo.Parsers.Service.validate(nil)
      iex> {changeset.valid?, changeset.errors}
      {false, [name: {"can't be blank", [validation: :required]}, platform: {"can't be blank", [validation: :required]}]}

      iex> BugsChannel.Repo.Parsers.Service.validate(%{}).valid?
      false

      iex> BugsChannel.Repo.Parsers.Service.validate(%{"id" => "1", "name" => "bar", "platform" => "python", "teams" => [ %{  "id" => "1", "name" => "foo" } ], "settings" => %{ "rate_limit" => 1, "auth_keys" => [ %{"key" => "key"}]} }).valid?
      true

  """
  def validate(doc), do: EctoUtils.validate_document(%RepoSchemas.Service{}, doc)

  @doc ~S"""
  Parse a map to Service, ServiceSettings, ServiceAuthKey, and Teams schemas.

  ## Examples

      iex> BugsChannel.Repo.Parsers.Service.parse(nil)
      nil

      iex> BugsChannel.Repo.Parsers.Service.parse(nil, %{})
      nil

      iex> BugsChannel.Repo.Parsers.Service.parse(%{}, nil)
      {:error, :invalid_schema}

      iex> BugsChannel.Repo.Parsers.Service.parse(%{"id" => "1", "name" => "bar", "platform" => "python", "teams" => [ %{  "id" => "1", "name" => "foo" } ], "settings" => %{ "rate_limit" => 1, "auth_keys" => [ %{"key" => "key"}]} }, %BugsChannel.Repo.Schemas.Service{})
      %BugsChannel.Repo.Schemas.Service{
        auth_keys: [],
        id: "1",
        name: "bar",
        platform: "python",
        settings: %BugsChannel.Repo.Schemas.ServiceSettings{rate_limit: 1},
        teams: [%BugsChannel.Repo.Schemas.Team{id: "1", name: "foo"}]
      }

  """
  def parse(doc), do: parse(doc, %RepoSchemas.Service{})

  def parse(nil, _schema), do: nil

  def parse(doc, %RepoSchemas.Service{} = schema)
      when is_map(doc) and is_struct(schema) do
    params = %{
      id: "#{doc["_id"] || doc["id"]}",
      name: doc["name"],
      platform: doc["platform"],
      teams: parse_teams(doc["teams"] || []),
      settings: parse_settings(doc["settings"] || %{}),
      auth_keys: parse_auth_keys(doc["auth_keys"] || [])
    }

    EctoUtils.parse_document(schema, params)
  end

  def parse(_doc, _schema), do: {:error, :invalid_schema}

  defp parse_settings(doc) when is_map(doc) do
    %{rate_limit: doc["rate_limit"]}
  end

  defp parse_teams(doc) when is_list(doc) do
    Enum.map(doc, &parse_team(&1))
  end

  defp parse_team(doc) when is_map(doc) do
    %{
      id: "#{doc["id"]}",
      name: doc["name"]
    }
  end

  defp parse_team(id) when is_binary(id) do
    %{"id" => id, "name" => "TODO: get_name_from_cache"}
  end

  defp parse_auth_keys(doc) when is_list(doc) do
    Enum.map(doc, fn auth_key ->
      %{
        key: auth_key["key"],
        disabled: auth_key["disabled"],
        expired_at: auth_key["expired_at"]
      }
    end)
  end

  @doc ~S"""
  Parse a document list to schemas.

  ## Examples
      iex> doc = %{
      ...>   "auth_keys" => [],
      ...>   "id" => "1",
      ...>   "name" => "bar",
      ...>   "platform" => "python",
      ...>   "settings" => %{"rate_limit" => 1},
      ...>   "teams" => [%{"id" => "1", "name" => "foo"}]
      ...> }
      ...> BugsChannel.Repo.Parsers.Service.parse_list([doc], %BugsChannel.Repo.Schemas.Service{})
      [%BugsChannel.Repo.Schemas.Service{id: "1", name: "bar", platform: "python", teams: [%BugsChannel.Repo.Schemas.Team{id: "1", name: "foo"}], settings: %BugsChannel.Repo.Schemas.ServiceSettings{rate_limit: 1}, auth_keys: []}]
  """
  def parse_list(docs, schema) when is_list(docs) and is_struct(schema) do
    Enum.map(docs, fn doc -> __MODULE__.parse(doc, schema) end)
  end
end
