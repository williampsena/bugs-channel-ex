defmodule BugsChannel.Channels.Gnat.ConsumerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  defmodule __MODULE__.FakeConsumer do
    use BugsChannel.Channels.Gnat.Consumer

    def dispatch_events(_message, _topic) do
      :ok
    end
  end

  alias __MODULE__.FakeConsumer
  alias BugsChannel.Channels.Gnat.{EventConsumer, RawEventConsumer}

  @consumers [FakeConsumer, EventConsumer, RawEventConsumer]

  setup do
    message = %{"foo" => "bar"}
    topic = "foo-bar"
    gnat_message = %{body: Jason.encode!(message), topic: topic}
    gnat_message_wrong = %{body: "body", topic: topic}

    [
      message: message,
      topic: topic,
      gnat_message: gnat_message,
      gnat_message_wrong: gnat_message_wrong
    ]
  end

  describe "dispatch_events/2" do
    test "should dispatch events", %{message: message, topic: topic} do
      Enum.each(@consumers, fn consumer ->
        assert consumer.dispatch_events(message, topic) == :ok
      end)
    end
  end

  describe "request/1" do
    test "should handle message", %{gnat_message: gnat_message} do
      Enum.each(@consumers, fn consumer ->
        assert consumer.request(gnat_message) == :ok
      end)
    end

    test "should raise error", %{gnat_message_wrong: gnat_message_wrong} do
      Enum.each(@consumers, fn consumer ->
        assert capture_log(fn ->
                 assert consumer.request(gnat_message_wrong) == :ok
               end) =~ "An error occurred while attempting to decode an event."
      end)
    end
  end

  describe "error/1" do
    test "should log error" do
      error = "invalid message"

      Enum.each(@consumers, fn consumer ->
        assert capture_log(fn ->
                 assert consumer.error(%{gnat: nil, reply_to: nil}, error) == :ok
               end) =~
                 "An error occurred while attempting to consuming an event. #{inspect(error)}"
      end)
    end
  end
end
