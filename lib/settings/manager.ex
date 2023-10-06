defmodule BugsChannel.Settings.Manager do
  @moduledoc """
  The module is in charge of loading settings manager
  """

  use Agent

  alias BugsChannel.Settings.Schemas.ConfigFile

  def start_link(_) do
    config = load_from_file()
    Agent.start_link(fn -> config end, name: __MODULE__)
  end

  def get_config_file() do
    Agent.get(__MODULE__, & &1)
  end

  def load_from_file() do
    load_from_file(config_filepath())
  end

  def load_from_file(filepath) when is_binary(filepath) do
    with {:ok, yaml} <- File.read(filepath),
         {:ok, config} <- YamlElixir.read_from_string(yaml, merge_anchors: true) do
      ConfigFile.parse(config)
    end
  end

  defp config_filepath(), do: Application.get_env(:bugs_channel, :config_file)
end
