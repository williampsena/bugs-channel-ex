defmodule BugsChannel.Utils.Maps do
  @moduledoc """
  This module includes functions for dealing with map conversions.
  """

  @ecto_meta_fields ~w(__meta__ schema)a

  @doc ~S"""
  Safely parse a map string to map atoms.

  ## Examples

      iex> BugsChannel.Utils.Maps.parse_map_atoms(%{"foo" => "bar", "bar" => "foo", "foo_bar" => "bar_foo"}, ~w(foo bar))
      %{foo: "bar", bar: "foo"}

  """
  def parse_map_atoms(map, allowed_keys) do
    map = Map.filter(map, fn {key, _value} -> key in allowed_keys end)

    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end

  @doc ~S"""
  Safely parse a struct to map atoms.

  ## Examples

    iex> service = %BugsChannel.Repo.Schemas.Service{
    ...>   id: "1",
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
    ...> BugsChannel.Utils.Maps.map_from_struct(service)
    %{
      auth_keys: [%{disabled: false, key: "key", expired_at: nil}],
      id: "1",
      name: "bar",
      platform: "python",
      settings: %{ rate_limit: 1 },
      teams: [%{id: "1", name: "foo"}]
    }

    iex> BugsChannel.Utils.Maps.map_from_struct(%{})
    %{}

  """
  def map_from_struct(struct), do: :maps.map(&do_map_from_struct/2, parse_struct(struct))

  def do_map_from_struct(_key, value), do: ensure_nested_map(value)

  defp ensure_nested_map(list) when is_list(list), do: Enum.map(list, &ensure_nested_map/1)

  defp ensure_nested_map(struct) when is_struct(struct) do
    :maps.map(&do_map_from_struct/2, parse_struct(struct))
  end

  defp ensure_nested_map(data), do: data

  defp parse_struct(struct) when is_struct(struct) do
    struct |> Map.from_struct() |> Map.drop(@ecto_meta_fields)
  end

  defp parse_struct(value), do: value

end
