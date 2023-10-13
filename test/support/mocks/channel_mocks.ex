defmodule BugsChannel.Mocks.ChannelMocks do
  @moduledoc """
  This is the module in charge of channel mocks using mox.
  """

  import Mox
  import ExUnit.Assertions

  def expect_channel_build_topic(event_id, topic) when is_binary(topic) do
    expect_channel_build_topic(event_id, topic, "#{topic}.#{event_id}")
  end

  def expect_channel_build_topic(event_id, topic, result) when is_binary(topic) do
    expect(ChannelMock, :build_topic, fn ^topic, ^event_id -> result end)
  end

  def expect_channel_publish(topic, message_contains)
      when is_binary(topic) and is_binary(message_contains) do
    do_expect_channel_publish(topic, message_contains, :ok)
  end

  def expect_channel_publish_error(topic, message_contains)
      when is_binary(topic) and is_binary(message_contains) do
    do_expect_channel_publish(topic, message_contains, {:error, "Too bad!"})
  end

  defp do_expect_channel_publish(topic, message_contains, result)
       when is_binary(topic) and is_binary(message_contains) do
    expect(ChannelMock, :publish, fn ^topic, event_message ->
      assert String.contains?(event_message, message_contains)
      result
    end)
  end
end
