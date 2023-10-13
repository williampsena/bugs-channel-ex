defmodule BugsChannel.Case.SettingsManagerTestCase do
  @moduledoc """
  This is the module in charge of supporting settings manager test cases.
  """
  require IEx

  defmacro __using__(__opts__) do
    quote do
      use ExUnit.Case, async: false

      alias BugsChannel.Settings.Manager, as: SettingsManager
      alias BugsChannel.Mocks.SettingsManagerMocks

      @default_settings_config_file "test/fixtures/settings/config.yml"

      setup context do
        setup_start_manager_agent(context)
        setup_start_manager_mocks(context)

        :ok
      end

      defp setup_start_manager_mocks(context) do
        if context[:starts_with_mocks], do: setup_manager_mocks_expectations()
      end

      defp setup_start_manager_agent(context) do
        starts_with_config_file = context[:starts_with_config_file]

        starts_with_config_file = get_settings_manager_config_file(starts_with_config_file)

        if is_binary(starts_with_config_file),
          do: start_settings_manager(starts_with_config_file)
      end

      defp get_settings_manager_config_file(config_file) do
        if config_file == :default,
          do: @default_settings_config_file,
          else: config_file
      end

      def reset_settings_manager_on_exit!(context) do
        on_exit(fn ->
          Application.put_env(:bugs_channel, :database_mode, "postgres")
          Application.put_env(:bugs_channel, :conf_file, nil)
        end)

        context
      end

      def setup_manager_mocks_expectations() do
        SettingsManagerMocks.expect_get_config_file()
      end

      def start_settings_manager(config_file \\ @default_settings_config_file) do
        Application.put_env(:bugs_channel, :conf_file, config_file)

        with {:ok, _pid} <-
               SettingsManager.start_link(database_mode: "dbless", config_file: config_file) do
          :ok
        end
      end
    end
  end
end
