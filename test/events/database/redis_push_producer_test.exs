defmodule BugsChannel.Events.Database.RedisPushProducerTest do
  use ExUnit.Case

  import Mock
  import ExUnit.CaptureLog
  import BugsChannel.Test.Support.FixtureHelper

  alias BugsChannel.Repo.Schemas, as: RepoSchemas
  alias BugsChannel.Events.Database.RedisPushProducer
  alias BugsChannel.Utils.Maps

  describe "start_link/1" do
    test "with default options" do
      assert match?({:ok, _}, RedisPushProducer.start_link([]))
    end
  end

  describe "init/1" do
    test "with default options" do
      assert RedisPushProducer.init([]) == {:ok, [done: 0, errors: 0, ignored: 0]}
    end
  end

  test "terminate/2" do
    assert capture_log(fn ->
             assert RedisPushProducer.terminate(nil, nil)
           end) =~ "The redis push producer has been terminated...."
  end

  describe "enqueue/2" do
    test "with default options" do
      assert RedisPushProducer.enqueue(:home, %{"foo" => "bar"}) == :ok
    end
  end

  describe "handle_cast/2" do
    setup do
      event = load_json_fixture("events/event.json")
      default_state = [done: 0, errors: 0, ignored: 0]

      [default_state: default_state, event: event]
    end

    test "with valid event", %{default_state: default_state, event: event} do
      assert RedisPushProducer.handle_cast({:home, event}, default_state) == {
               :noreply,
               [done: 1, errors: 0, ignored: 0]
             }
    end

    test "when an issue occurred while attempting to push an event", %{
      default_state: default_state,
      event: event
    } do
      {:ok, encoded_event} = RepoSchemas.Event.parse(event)

      encoded_event =
        encoded_event
        |> Maps.map_from_struct()
        |> Jason.encode!()

      with_mock(Redix, [:passthrough],
        command: fn :redix, ["LPUSH", "events", _] -> {:error, "invalid connection"} end
      ) do
        assert RedisPushProducer.handle_cast({:home, event}, default_state) ==
                 {:noreply, [errors: 1, done: 0, ignored: 0]}

        assert_called(Redix.command(:redix, ["LPUSH", "events", encoded_event]))
      end
    end

    test "when an unexpected issue occurred while attempting to push an event", %{
      default_state: default_state,
      event: event
    } do
      with_mock(Redix, [:passthrough],
        command: fn :redix, ["LPUSH", "events", _] -> raise "invalid connection" end
      ) do
        assert capture_log(fn ->
                 assert RedisPushProducer.handle_cast({:home, event}, default_state) ==
                          {:noreply, [errors: 1, done: 0, ignored: 0]}
               end) =~
                 "❌ An unexpected error occurred while attempting to push events to Redis.%RuntimeError{message: \"invalid connection\"}"

        assert_called(Redix.command(:_, :_))
      end
    end

    test "when an event is ignored", %{default_state: default_state} do
      assert RedisPushProducer.handle_cast({:home, nil}, default_state) ==
               {:noreply, [ignored: 1, done: 0, errors: 0]}
    end
  end
end
