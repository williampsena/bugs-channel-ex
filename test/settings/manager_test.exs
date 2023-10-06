defmodule BugsChannel.Settings.ManagerTest do
  use ExUnit.Case

  alias BugsChannel.Settings.Manager, as: SettingsManager

  setup do
    on_exit(fn ->
      Application.put_env(:bugs_channel, :dbless, "postgres")
      Application.put_env(:bugs_channel, :conf_file, nil)
    end)

    config_file =
      %BugsChannel.Settings.Schemas.ConfigFile{
        org: "foo",
        services: [
          %BugsChannel.DB.Schemas.Service{
            id: 1,
            name: "foo bar service",
            platform: "python",
            settings: %{"auth-keys" => [%{"key" => "key"}], "rate-limit" => 1},
            team: "foo"
          }
        ],
        teams: [
          %BugsChannel.DB.Schemas.Team{
            id: 1,
            name: "foo"
          }
        ],
        version: "1"
      }

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

  test "start_link/1" do
    Application.put_env(:bugs_channel, :config_file, "test/fixtures/settings/config.yml")
    Application.put_env(:bugs_channel, :database_mode, "dbless")

    assert match?({:ok, _}, SettingsManager.start_link(nil))
  end

  test "get_config_file/1" do
    {:ok, _pid} = SettingsManager.start_link(nil)

    assert SettingsManager.get_config_file() == {
             :ok,
             %BugsChannel.Settings.Schemas.ConfigFile{
               id: nil,
               version: "1",
               org: "foo",
               services: [
                 %BugsChannel.DB.Schemas.Service{
                   id: 1,
                   name: "foo bar service",
                   platform: "python",
                   team: "foo",
                   settings: %{"auth-keys" => [%{"key" => "key"}], "rate-limit" => 1}
                 }
               ],
               teams: [
                 %BugsChannel.DB.Schemas.Team{id: 1, name: "foo"}
               ]
             }
           }
  end
end
