defmodule BugsChannel.Events.ProducerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import Mox
  import BugsChannel.Test.Support.FixtureHelper
  import BugsChannel.Mocks.ChannelMocks

  alias BugsChannel.Events.Producer, as: EventProducer

  setup :verify_on_exit!

  describe "start_link/1" do
    test "with default options" do
      assert match?({:ok, _}, EventProducer.start_link([]))
    end
  end

  describe "init/1" do
    test "with default options" do
      assert EventProducer.init([]) == {:ok, [{:events, []}, {:events_missed, 0}]}
    end
  end

  test "terminate/2" do
    assert capture_log(fn ->
             assert EventProducer.terminate(nil, nil)
           end) =~ "The event producer has been terminated...."
  end

  describe "enqueue/2" do
    test "with default options" do
      assert EventProducer.enqueue(:sentry, %{"foo" => "bar"}) == :ok
    end
  end

  describe "handle_cast/2" do
    setup do
      event = load_json_fixture("events/event.json")
      sentry_event = load_json_fixture("sentry/event.json")
      event_id = event["id"]
      event_topic = "event"
      topic = "#{event_topic}.#{event_id}"
      default_state = [events: [], events_missed: 0]

      [
        default_state: default_state,
        event: event,
        sentry_event: sentry_event,
        event_id: event_id,
        topic: topic,
        event_topic: event_topic
      ]
    end

    test "with valid event", %{
      default_state: default_state,
      event_id: event_id,
      topic: topic,
      event: event,
      event_topic: event_topic
    } do
      expect_channel_build_topic(event_id, event_topic)
      expect_channel_publish(topic, event_id)

      assert EventProducer.handle_cast({:home, event}, default_state) == {
               :noreply,
               [events: [event_id], events_missed: 0]
             }
    end

    test "with valid sentry event", %{
      default_state: default_state,
      event_id: event_id,
      topic: topic,
      sentry_event: sentry_event,
      event_topic: event_topic
    } do
      expect_channel_build_topic(event_id, event_topic)
      expect_channel_publish(topic, event_id)

      assert EventProducer.handle_cast({:sentry, sentry_event}, default_state) == {
               :noreply,
               [events: [event_id], events_missed: 0]
             }
    end

    test "with invalid events", %{default_state: default_state} do
      assert EventProducer.handle_cast({:home, %{"foo" => "bar"}}, default_state) ==
               {:noreply, [events_missed: 1, events: []]}
    end

    test "when an issue occurred while attempting to push an event", %{
      default_state: default_state,
      event_id: event_id,
      topic: topic,
      event: event,
      event_topic: event_topic
    } do
      expect_channel_build_topic(event_id, event_topic)
      expect_channel_publish_error(topic, event_id)

      assert EventProducer.handle_cast({:home, event}, default_state) ==
               {:noreply, [events_missed: 1, events: []]}
    end
  end
end
