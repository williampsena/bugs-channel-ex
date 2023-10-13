defmodule BugsChannel.Mocks.SettingsManagerMocks do
  @moduledoc """
  This is the module in charge of settings manager mocks using mox.
  """
  import BugsChannel.Factories.ConfigFile
  import Mox

  def expect_get_config_file() do
    config_file = config_file_factory()
    expect(SettingsManagerMock, :get_config_file, fn -> config_file end)
  end
end
