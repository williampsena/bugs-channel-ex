defmodule BugsChannel.Settings.Behaviours.Manager do
  @moduledoc """
  This module contains settings manager behaviors.
  """
  alias alias BugsChannel.Settings.Schemas.ConfigFile

  @callback get_config_file() :: ConfigFile
  @callback load_from_file() :: {:ok, config_file :: ConfigFile} | {:error, reason :: term}
  @callback load_from_file(String.t()) ::
              {:ok, config_file :: ConfigFile} | {:error, reason :: term}
end
