defmodule BugsChannel.Channels.Gnat.RawEventConsumerTest do
  use ExUnit.Case

  import Mock

  alias BugsChannel.Channels.Gnat.RawEventConsumer
  alias BugsChannel.Events.Producer, as: EventProducer

  describe "dispatch_events/2" do
    setup do
      message = %{"foo" => "bar", "x-origin" => "home"}
      topic = "foo-bar"

      [message: message, topic: topic]
    end

    test "should dispatch events", %{message: message, topic: topic} do
      with_mock(EventProducer, [:passthrough], enqueue: fn :home, ^message -> :ok end) do
        assert RawEventConsumer.dispatch_events(message, topic) == :ok
      end
    end
  end
end
