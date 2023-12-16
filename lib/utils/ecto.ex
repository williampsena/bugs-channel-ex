defmodule BugsChannel.Utils.Ecto do
  @moduledoc """
  This module is in charge of transforming ecto errors to plain lists.
  """

  alias BugsChannel.Utils.Maps

  @doc ~S"""
  Parses ecto changeset errors to list

  ## Examples

    iex> BugsChannel.Utils.Ecto.translate_errors({:ok, %Ecto.Changeset{ valid?: false, errors: [ service_id: {"is invalid", [type: :integer, validation: :cast]}, stack_trace: {"is invalid", [type: {:array, :map}, validation: :cast]} ] } })
    ["service_id: is invalid", "stack_trace: is invalid"]

    iex> BugsChannel.Utils.Ecto.translate_errors({:ok, %Ecto.Changeset{ valid?: false, errors: [ foo: :bar, service_id: {"is invalid", [type: :integer, validation: :cast]}, stack_trace: {"is invalid", [type: {:array, :map}, validation: :cast]} ] } })
    ["foo: :bar", "service_id: is invalid", "stack_trace: is invalid"]

    iex> BugsChannel.Utils.Ecto.translate_errors(:ok)
    []
  """
  def translate_errors({_, %Ecto.Changeset{errors: errors, valid?: false}}) do
    Enum.map(errors, fn {field, error} ->
      case error do
        {message, _opts} ->
          "#{field}: #{message}"

        error ->
          "#{field}: #{inspect(error)}"
      end
    end)
  end

  def translate_errors(_errors), do: []

  @doc ~S"""
  Parses to map persistent without ecto fields.

  ## Examples

    iex> service = %BugsChannel.Repo.Schemas.Service{
    ...>   id: "1",
    ...>  __meta__: %{},
    ...>   name: "bar",
    ...>   platform: "python",
    ...>   auth_keys: [
    ...>     %BugsChannel.Repo.Schemas.ServiceAuthKey{
    ...>       key: "key",
    ...>       disabled: false,
    ...>       expired_at: nil
    ...>     }
    ...>   ],
    ...>   settings: %BugsChannel.Repo.Schemas.ServiceSettings{ rate_limit: 1 },
    ...>   teams: [ %BugsChannel.Repo.Schemas.Team{ id: "1", name: "foo" } ]
    ...> }
    ...> BugsChannel.Utils.Ecto.parse_to_map_persistent(service)
    %{
      auth_keys: [%{disabled: false, key: "key", expired_at: nil}],
      name: "bar",
      platform: "python",
      settings: %{ rate_limit: 1 },
      teams: [%{ id: "1", name: "foo" }]
    }

    iex> BugsChannel.Utils.Ecto.parse_to_map_persistent(%{ foo: :bar})
    %{foo: :bar}
  """
  def parse_to_map_persistent(schema) do
    schema
    |> Map.delete(:id)
    |> Maps.map_from_struct()
  end

  @doc ~S"""
  Parses map to defined schema

  ## Examples

      iex> BugsChannel.Utils.Ecto.parse_document(%BugsChannel.Repo.Schemas.Service{}, %{id: "1", name: "bar", platform: "python", teams: [ %{  id: "1", name: "foo" } ], settings: %{ rate_limit: 1 }, auth_keys: [ %{ key: "key" } ] })
      %BugsChannel.Repo.Schemas.Service{
        auth_keys: [%BugsChannel.Repo.Schemas.ServiceAuthKey{key: "key", disabled: false, expired_at: nil}],
        id: "1",
        name: "bar",
        platform: "python",
        settings: %BugsChannel.Repo.Schemas.ServiceSettings{ rate_limit: 1 },
        teams: [%BugsChannel.Repo.Schemas.Team{ id: "1", name: "foo"}]
      }

      iex> BugsChannel.Utils.Ecto.parse_document(%BugsChannel.Repo.Schemas.Service{}, nil, %{})
      {:error, :invalid_document}

      iex> BugsChannel.Utils.Ecto.parse_document(%BugsChannel.Repo.Schemas.Service{}, %{id: "1",  teams: "foo", settings: %{ rate_limit: 1 }, auth_keys: [ %{key: "key"} ] })
      {:error, :invalid_document}
  """
  def parse_document(schema, doc), do: parse_document(schema, doc, nil)

  def parse_document(schema, doc, default_value) when is_struct(schema) and is_map(doc) do
    result = Ecto.Changeset.change(schema, doc || default_value)

    case Ecto.Changeset.apply_action(result, :update) do
      {:ok, data} -> data
      {:error, _changeset} -> {:error, :invalid_document}
    end
  end

  def parse_document(_schema, _map, _default_value), do: {:error, :invalid_document}
end
