defmodule BugsChannel.Channels.Gnat.ChannelTest do
  use ExUnit.Case
  import Mock

  alias BugsChannel.Channels.Gnat.Channel, as: GnatChannel

  doctest GnatChannel

  describe "publish/2" do
    setup do
      message = Jason.encode!(%{"foo" => "bar"})
      topic = "foo-bar"

      [message: message, topic: topic]
    end

    test "should publish message", %{message: message, topic: topic} do
      with_mock(Gnat, [:passthrough], pub: fn :gnat, ^topic, ^message -> :ok end) do
        assert GnatChannel.publish(topic, message) == :ok
        assert_called(Gnat.pub(:gnat, topic, message))
      end
    end

    test "should raise error", %{message: message, topic: topic} do
      with_mock(Gnat, [:passthrough], pub: fn :gnat, ^topic, ^message -> raise "fatal error" end) do
        assert GnatChannel.publish(topic, message) == {:error, :gnat_publish_failed}
        assert_called(Gnat.pub(:gnat, topic, message))
      end
    end
  end
end
