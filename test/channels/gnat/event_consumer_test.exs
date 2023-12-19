defmodule BugsChannel.Channels.Gnat.EventConsumerTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias BugsChannel.Channels.Gnat.EventConsumer

  describe "dispatch_events/2" do
    setup do
      message = %{"foo" => "bar"}
      topic = "foo-bar"

      [message: message, topic: topic]
    end

    setup do
      on_exit(fn ->
        Application.put_env(:bugs_channel, :database_mode, "dbless")
      end)

      :ok
    end

    test "should dispatch events", %{message: message, topic: topic} do
      Application.put_env(:bugs_channel, :database_mode, "mongo")

      assert capture_log(fn ->
               assert EventConsumer.dispatch_events(message, topic) == :ok
             end) =~ "The message was delivered to mongo writer producer."
    end

    test "should not dispatch events when the mongo database mode is not active", %{
      message: message,
      topic: topic
    } do
      Application.put_env(:bugs_channel, :database_mode, "dbless")

      assert capture_log(fn ->
               assert EventConsumer.dispatch_events(message, topic) == :ok
             end) =~ "Dead letter (foo-bar) not implemented yet."
    end
  end
end
