defmodule Mix.Tasks.ImportTest do
  use ExUnit.Case

  import Mock

  describe "run/1" do
    test "with invalid dump file location" do
      assert_raise Mix.Error,
                   "Please provide the dump file location. 🥺",
                   fn ->
                     Mix.Tasks.Import.run([])
                   end
    end

    test "with invalid format" do
      config_invalid = "./test/fixtures/settings/config_invalid.yml"

      assert_raise Mix.Error,
                   "The dump file is in the wrong format. 😔",
                   fn ->
                     Mix.Tasks.Import.run([config_invalid])
                   end
    end

    test "with valid format" do
      with_mock(Mongo, [], update_one: fn :mongo, _, _, _, _ -> :ok end) do
        config = "./test/fixtures/settings/config.yml"

        Mix.Tasks.Import.run([config])
      end
    end

    test "with database error" do
      with_mock(Mongo, [], update_one: fn :mongo, _, _, _, _ -> {:error, "error"} end) do
        config = "./test/fixtures/settings/config.yml"

        Mix.Tasks.Import.run([config])
      end
    end
  end
end
