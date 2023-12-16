defmodule BugsChannel.Repo.Parsers.Service do
  @moduledoc """
  This module includes database document parsers or mappers for the Service entity.
  """

  alias BugsChannel.Utils.Ecto, as: EctoUtils

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  @doc ~S"""
  Parse a map to Service, ServiceSettings, ServiceAuthKey, and Teams schemas.

  ## Examples

      iex> BugsChannel.Repo.Parsers.Service.parse(nil, %{})
      nil

      iex> BugsChannel.Repo.Parsers.Service.parse(nil, %{}, :map)
      :map

      iex> BugsChannel.Repo.Parsers.Service.parse(%{}, nil, %{})
      {:error, :invalid_schema}

      iex> BugsChannel.Repo.Parsers.Service.parse(%{"id" => "1", "name" => "bar", "platform" => "python", "teams" => [ %{  "id" => "1", "name" => "foo" } ], "settings" => %{ "rate_limit" => 1, "auth_keys" => [ %{"key" => "key"}]} }, %BugsChannel.Repo.Schemas.Service{},  nil)
      %BugsChannel.Repo.Schemas.Service{
        auth_keys: [],
        id: "",
        name: "bar",
        platform: "python",
        settings: %BugsChannel.Repo.Schemas.ServiceSettings{rate_limit: 1},
        teams: [%BugsChannel.Repo.Schemas.Team{id: "1", name: "foo"}]
      }

  """
  def parse(doc, schema), do: parse(doc, schema, nil)

  def parse(_doc, nil, _default_value), do: {:error, :invalid_schema}

  def parse(nil, _schema, default_value), do: default_value

  def parse(doc, %RepoSchemas.Service{} = schema, default_value)
      when is_map(doc) and is_struct(schema) do
    params = %{
      id: "#{doc["_id"]}",
      name: doc["name"],
      platform: doc["platform"],
      teams: parse(doc["teams"], %RepoSchemas.Team{}, []),
      settings: parse(doc["settings"], %RepoSchemas.ServiceSettings{}, %{}),
      auth_keys: parse(doc["auth_keys"], %RepoSchemas.ServiceAuthKey{}, [])
    }

    EctoUtils.parse_document(schema, params, default_value)
  end

  def parse(doc, %RepoSchemas.ServiceSettings{} = schema, default_value)
      when is_map(doc) and is_struct(schema) do
    EctoUtils.parse_document(schema, %{rate_limit: doc["rate_limit"]}, default_value)
  end

  def parse(doc, %RepoSchemas.Team{} = schema, default_value)
      when is_list(doc) and is_struct(schema) do
    Enum.map(doc, fn team ->
      EctoUtils.parse_document(
        schema,
        %{
          id: "#{team["id"]}",
          name: team["name"]
        },
        default_value
      )
    end)
  end

  def parse(doc, %RepoSchemas.ServiceAuthKey{} = schema, default_value)
      when is_list(doc) and is_struct(schema) do
    Enum.map(doc, fn auth_key ->
      EctoUtils.parse_document(
        schema,
        %{
          key: auth_key["key"],
          disabled: auth_key["disabled"],
          expired_at: auth_key["expired_at"]
        },
        default_value
      )
    end)
  end
end
