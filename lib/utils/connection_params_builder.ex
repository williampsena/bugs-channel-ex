defmodule BugsChannel.Utils.ConnectionParamsBuilder do
  @moduledoc """
  This module includes functions for build connection params.
  """

  @doc ~S"""
  Convert url to connection parameters

  ## Examples

      iex> BugsChannel.Utils.ConnectionParamsBuilder.from_url("gnat://user:password@localhost:4222?auth_required=true", auth_required: :boolean)
      {"gnat",
      %{
        port: 4222,
        host: "localhost",
        password: "password",
        username: "user",
        auth_required: true,
        path: ""
      }}

      iex> BugsChannel.Utils.ConnectionParamsBuilder.from_url("redis://localhost:5432")
      {"redis", %{port: 5432, host: "localhost", path: "" }}

      iex> BugsChannel.Utils.ConnectionParamsBuilder.from_url("amqp://user:pass@host:5672/vhost?heartbeat=60&wrong=true", heartbeat: :number)
      {"amqp", %{port: 5672, host: "host", password: "pass", username: "user", heartbeat: 1, path: "vhost"}}

      iex> BugsChannel.Utils.ConnectionParamsBuilder.from_url("sql://user:pass@host:8000/?number=1&boolean=true&boolean_num=1", number: :number, boolean: :boolean, boolean_num: :boolean)
      {"sql",
      %{
        port: 8000,
        boolean: true,
        host: "host",
        number: 1,
        password: "pass",
        username: "user",
        boolean_num: false,
        path: ""
      }}

      iex> BugsChannel.Utils.ConnectionParamsBuilder.from_url("fake://foo:80?bar=yes", bar: :any)
      {"fake", %{port: 80, host: "foo", bar: "yes", path: "" }}
  """
  def from_url(url, config_schema \\ []) when is_binary(url) and is_list(config_schema) do
    uri = URI.parse(url)

    connection_type = uri.scheme

    connection_config =
      %{
        host: uri.host,
        port: uri.port,
        path: String.slice(uri.path || "", 1..-1)
      }
      |> build_credentials(uri)
      |> build_query_params(config_schema, uri)

    {connection_type, connection_config}
  end

  defp build_credentials(connection_config, %URI{userinfo: nil}), do: connection_config

  defp build_credentials(connection_config, %URI{userinfo: userinfo}) do
    [username, password] = String.split(userinfo, ":")
    Map.merge(connection_config, %{username: username, password: password})
  end

  defp build_query_params(connection_config, config_schema, %URI{query: query}) do
    query_params = URI.decode_query(query || "")

    query_params =
      Enum.reduce(query_params, %{}, fn {key, value}, acc ->
        atom_key = String.to_atom(key)
        type = config_schema[atom_key]

        if is_nil(type) do
          acc
        else
          Map.put(acc, atom_key, parse_value(value, type))
        end
      end)

    Map.merge(connection_config, query_params)
  end

  defp parse_value(value, type) do
    case type do
      :boolean -> value == "true" || value == 1
      :number -> 1
      _ -> value
    end
  end
end
