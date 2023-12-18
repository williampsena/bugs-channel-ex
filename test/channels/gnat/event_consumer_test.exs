defmodule BugsChannel.Channels.Gnat.EventConsumerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias BugsChannel.Channels.Gnat.EventConsumer

  describe "dispatch_events/2" do
    setup do
      message = %{"foo" => "bar"}
      topic = "foo-bar"

      [message: message, topic: topic]
    end

    test "should dispatch events", %{message: message, topic: topic} do
      assert capture_log(fn ->
               assert EventConsumer.dispatch_events(message, topic) == :ok
             end) =~ "The message was delivered to mongo writer producer."
    end
  end
end
