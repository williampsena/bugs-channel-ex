defmodule Mix.Tasks.DatabaseCleanupTest do
  use ExUnit.Case

  import Mock

  describe "run/1" do
    test "when the mongo database is successfully deleted" do
      with_mock(Mongo, [],
        start_link: fn _ -> {:ok, :pid} end,
        drop_database: fn :mongo_admin, "bugs-channel-test" -> :ok end
      ) do
        Mix.Tasks.DatabaseCleanup.run([])
      end
    end

    test "when an error struct occurs while attempting to delete the mongo database" do
      with_mock(Mongo, [],
        start_link: fn _ -> {:ok, :pid} end,
        drop_database: fn :mongo_admin, "bugs-channel-test" ->
          raise %ArgumentError{message: "Invalid connection. 🥺"}
        end
      ) do
        assert_raise Mix.Error,
                     "Invalid connection. 🥺",
                     fn ->
                       Mix.Tasks.DatabaseCleanup.run([])
                     end
      end
    end

    test "when an error occurs because mongo connection url is invalid" do
      with_mock(Mongo, [], start_link: fn _ -> {:ok, :pid} end) do
        mongo_opts = Application.get_env(:bugs_channel, :mongo)

        on_exit(fn ->
          Application.put_env(:bugs_channel, :mongo, mongo_opts)
        end)

        updated_mongo_opts = Keyword.put(mongo_opts, :connection_url, "mongodb://localhost:27017")

        Application.put_env(:bugs_channel, :mongo, updated_mongo_opts)

        assert_raise Mix.Error,
                     "The mongo connection is invalid. 😔",
                     fn ->
                       Mix.Tasks.DatabaseCleanup.run([])
                     end
      end
    end

    test "when an error occurs while attempting to delete the mongo database" do
      with_mock(Mongo, [],
        start_link: fn _ -> {:ok, :pid} end,
        drop_database: fn :mongo_admin, "bugs-channel-test" ->
          raise "Invalid connection. 🥺"
        end
      ) do
        assert_raise Mix.Error,
                     "%RuntimeError{message: \"Invalid connection. 🥺\"}",
                     fn ->
                       Mix.Tasks.DatabaseCleanup.run([])
                     end
      end
    end

    test "when an error occurs while attempting to delete the mongo database on production environment" do
      with_mock(
        Mix,
        [:passthrough],
        env: fn -> :prod end
      ) do
        assert_raise Mix.Error,
                     "This task hadn't been designed to be run in a production environment. 🥺",
                     fn ->
                       Mix.Tasks.DatabaseCleanup.run([])
                     end
      end
    end
  end
end
