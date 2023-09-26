defmodule BugsChannel.Utils.Config do
  @moduledoc """
  This module presents routines for getting application configuration and environment info.
  """

  @doc ~S"""
  Check out if the current environment is development

  ## Examples

      iex> BugsChannel.Utils.Config.development?()
      false

  """
  def development?(), do: env() == :dev

  @doc ~S"""
  Check out if the current environment is production

  ## Examples

      iex> BugsChannel.Utils.Config.production?()
      false

  """
  def production?(), do: env() == :prod

  @doc ~S"""
  Check out if the current environment is test

  ## Examples

      iex> BugsChannel.Utils.Config.test?()
      true

  """
  def test?(), do: env() == :test

  @doc ~S"""
  Get the current environment name

  ## Examples

      iex> BugsChannel.Utils.Config.env()
      :test

  """
  def env(), do: Application.get_env(:bugs_channel, :environment)
end
