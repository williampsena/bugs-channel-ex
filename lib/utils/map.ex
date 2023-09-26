defmodule BugsChannel.Utils.Maps do
  @moduledoc """
  This module includes functions for dealing with map conversions.
  """

  @doc ~S"""
  Safely parse a map string to map atoms.

  ## Examples

      iex> BugsChannel.Utils.Maps.parse_map_atoms(%{"foo" => "bar", "bar" => "foo"}, ~w(foo bar))
      %{foo: "bar", bar: "foo"}

  """
  def parse_map_atoms(map, allowed_keys) do
    map = Map.filter(map, fn {key, _value} -> key in allowed_keys end)

    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
