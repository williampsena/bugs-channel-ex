defmodule BugsChannelTest do
  use ExUnit.Case

  import Mock
  import ExUnit.CaptureLog

  setup do
    sentry_config = Application.get_env(:bugs_channel, :sentry)
    gnat_config = Application.get_env(:bugs_channel, :gnat)

    on_exit(fn ->
      Application.put_env(:bugs_channel, :sentry, sentry_config)
      Application.put_env(:bugs_channel, :gnat, gnat_config)
    end)

    [sentry_config: sentry_config, gnat_config: gnat_config]
  end

  test "init/1" do
    assert BugsChannel.init(:foo) == :foo
  end

  describe "test startup behaviours" do
    test "with default startup" do
      with_mock(Supervisor, start_link: fn _children, _opts -> {:ok, :skip} end) do
        assert capture_log(fn ->
                 assert BugsChannel.start([], []) == {:ok, :skip}
               end) =~ "🐛 Starting application..."

        assert_called(
          Supervisor.start_link(
            [{Bandit, [plug: BugsChannel.Router, port: 4000]}, {BugsChannel.Events.Producer, []}],
            strategy: :one_for_one,
            name: BugsChannel.Supervisor
          )
        )
      end
    end

    test "with sentry server" do
      Application.put_env(:bugs_channel, :sentry, enabled: true, port: 4001)

      with_mock(Supervisor, start_link: fn _children, _opts -> {:ok, :skip} end) do
        assert BugsChannel.start([], []) == {:ok, :skip}

        assert_called(
          Supervisor.start_link(
            [
              {Bandit, [plug: BugsChannel.Router, port: 4000]},
              {Bandit, [plug: BugsChannel.Plugins.Sentry.Router, port: 4001]},
              {BugsChannel.Events.Producer, []}
            ],
            strategy: :one_for_one,
            name: BugsChannel.Supervisor
          )
        )
      end
    end

    test "with gnat" do
      Application.put_env(:bugs_channel, :gnat, enabled: true)

      with_mock(Supervisor, [:passthrough], start_link: fn _children, _opts -> {:ok, :skip} end) do
        assert BugsChannel.start([], []) == {:ok, :skip}

        assert_called(
          Supervisor.start_link(
            [
              {Bandit, [plug: BugsChannel.Router, port: 4000]},
              {Gnat.ConnectionSupervisor,
               %{name: :gnat, backoff_period: 4000, connection_settings: [%{enabled: true}]}},
              %{
                id: :"raw-event.*",
                start:
                  {Gnat.ConsumerSupervisor, :start_link,
                   [
                     %{
                       module: BugsChannel.Channels.Gnat.RawEventConsumer,
                       shutdown: 30_000,
                       connection_name: :gnat,
                       subscription_topics: [%{queue_group: "RawEvents", topic: "raw-event.*"}]
                     }
                   ]}
              },
              %{
                id: :"event.*",
                start:
                  {Gnat.ConsumerSupervisor, :start_link,
                   [
                     %{
                       module: BugsChannel.Channels.Gnat.EventConsumer,
                       shutdown: 30_000,
                       connection_name: :gnat,
                       subscription_topics: [%{queue_group: "Events", topic: "event.*"}]
                     }
                   ]}
              },
              {BugsChannel.Events.Producer, []}
            ],
            strategy: :one_for_one,
            name: BugsChannel.Supervisor
          )
        )
      end
    end
  end
end
