defmodule BugsChannel.ConfigBuilder do
  @moduledoc """
  This module includes functions for setup environments.
  """

  @doc ~S"""
  Get the value from the environment variables and convert it to a list.

  ## Examples

      iex> BugsChannel.Utils.ConfigBuilder.list_from_env("FOO", "foo|bar")
      ["foo", "bar"]

  """
  def list_from_env(key, default_value, delimiter \\ "|") do
    String.split(System.get_env(key, default_value), delimiter)
  end
end
