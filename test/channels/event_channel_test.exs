defmodule BugsChannel.Channels.EventChannelTest do
  use ExUnit.Case

  import Mox
  import Mock
  import BugsChannel.Mocks.ChannelMocks

  alias BugsChannel.Channels.EventChannel

  doctest EventChannel

  setup :verify_on_exit!

  setup do
    [
      topic: "foo-bar",
      event_id: "1",
      event_topic: "foo-bar.1",
      message: Jason.encode!(%{"foo" => "bar"})
    ]
  end

  describe "publish/2" do
    test "with success", %{event_topic: event_topic, message: message} do
      expect_channel_publish(event_topic, "foo")

      assert EventChannel.publish("foo-bar.1", message) == :ok
    end

    test "with error", %{event_topic: event_topic, message: message} do
      expect_channel_publish_error(event_topic, "foo")

      assert EventChannel.publish("foo-bar.1", message) == {:error, "Too bad!"}
    end

    test "with fatal error", %{event_topic: event_topic, message: message} do
      with_mock(ChannelMock, [:passthrough], publish: fn ^event_topic, ^message -> raise "oops" end) do
        assert EventChannel.publish("foo-bar.1", message) == {:error, :publish_failed}
      end
    end
  end

  describe "build_topic/2" do
    test "with some topic", %{
      topic: topic,
      event_id: event_id,
      event_topic: event_topic
    } do
      expect_channel_build_topic(event_id, topic)

      assert EventChannel.build_topic("foo-bar", event_id) == event_topic
    end
  end
end
