defmodule BugsChannel.Repo.Parsers.Base do
  @moduledoc """
  This module includes database document parsers or mappers for entities.
  """

  defmacro __using__(__opts__) do
    quote location: :keep do
      alias BugsChannel.Utils.Maps

      @doc ~S"""
      Parse a map to schema.

      ## Examples
          iex> service = %BugsChannel.Repo.Schemas.Service{
          ...>   auth_keys: [],
          ...>   id: "1",
          ...>   name: "bar",
          ...>   platform: "python",
          ...>   settings: %BugsChannel.Repo.Schemas.ServiceSettings{rate_limit: 1},
          ...>   teams: [%BugsChannel.Repo.Schemas.Team{id: "1", name: "foo"}]
          ...> }
          ...> BugsChannel.Repo.Parsers.Service.parse_to_document(service, :insert)
          %{
            auth_keys: [],
            name: "bar",
            platform: "python",
            settings: %{rate_limit: 1},
            teams: [%{id: "1", name: "foo"}]
          }

          iex> BugsChannel.Repo.Parsers.Service.parse_to_document(nil, :insert)
          nil

          iex> service = %BugsChannel.Repo.Schemas.Service{
          ...>   auth_keys: [],
          ...>   id: "1",
          ...>   name: "bar",
          ...>   platform: "python",
          ...>   settings: %BugsChannel.Repo.Schemas.ServiceSettings{rate_limit: 1},
          ...>   teams: [%BugsChannel.Repo.Schemas.Team{id: "1", name: "foo"}]
          ...> }
          ...> BugsChannel.Repo.Parsers.Service.parse_to_document(service, :update)
          %{
            auth_keys: [],
            id: "1",
            name: "bar",
            platform: "python",
            settings: %{rate_limit: 1},
            teams: [%{id: "1", name: "foo"}]
          }
      """
      def parse_to_document(schema, action)
          when is_struct(schema) and action in ~w(insert update)a do
        map = Maps.map_from_struct(schema)

        if action == :insert,
          do: Map.delete(map, :id),
          else: map
      end

      def parse_to_document(_, _), do: nil

      defp invalid_schema_error, do: {:error, :invalid_schema}
    end
  end
end
