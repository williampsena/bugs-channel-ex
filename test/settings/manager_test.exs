defmodule BugsChannel.Settings.ManagerTest do
  use BugsChannel.Case.SettingsManagerTestCase
  import BugsChannel.Factories.ConfigFile

  alias BugsChannel.Settings.Manager, as: SettingsManager

  setup :reset_settings_manager_on_exit!

  setup do
    config_file = build(:config_file)

    [config_file: config_file]
  end

  describe "load_from_file" do
    test "with invalid yaml" do
      assert SettingsManager.load_from_file("test/fixtures/settings/config_invalid.yml") == {
               :error,
               %YamlElixir.ParsingError{
                 __exception__: true,
                 column: 9,
                 line: 1,
                 message: "Block mapping value not allowed here",
                 type: :block_mapping_value_not_allowed
               }
             }
    end

    test "with default file", %{config_file: config_file} do
      Application.put_env(:bugs_channel, :config_file, "test/fixtures/settings/config.yml")

      assert SettingsManager.load_from_file() == {:ok, config_file}
    end

    test "with specified file", %{config_file: config_file} do
      assert SettingsManager.load_from_file("test/fixtures/settings/config.yml") ==
               {:ok, config_file}
    end
  end

  describe "start_link/1" do
    setup do
      Application.put_env(:bugs_channel, :config_file, "test/fixtures/settings/config.yml")

      :ok
    end

    test "without options" do
      assert match?({:ok, _}, SettingsManager.start_link(nil))
    end

    test "with options" do
      assert match?(
               {:ok, _},
               SettingsManager.start_link(config_file: "test/fixtures/settings/config.yml")
             )
    end

    test "with nil" do
      Application.put_env(:bugs_channel, :config_file, nil)

      assert SettingsManager.start_link([]) == :invalid_config_file
    end
  end

  @tag starts_with_config_file: :default
  test "get_config_file/1", %{config_file: config_file} do
    assert SettingsManager.get_config_file() == config_file
  end
end
