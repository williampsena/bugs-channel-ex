defmodule BugsChannel.Channels.Gnat.Channel do
  @moduledoc """
  The module is in responsible for push messages to NATs.
  """
  require Logger

  @behaviour BugsChannel.Channels.Behaviours.Channel

  def publish(topic, message) when is_binary(topic) and is_binary(message) do
    try do
      with :ok <- Gnat.pub(:gnat, topic, message) do
        :ok
      end
    rescue
      e ->
        Logger.error("An error occurred while attempting to publish a message. #{inspect(e)}")
        {:error, :gnat_publish_failed}
    end
  end

  @doc ~S"""
  Get topic name

  ## Examples

      iex> BugsChannel.Channels.Gnat.Channel.build_topic("foo-bar", 1)
      "foo-bar.1"

  """
  def build_topic(prefix, id) when is_binary(prefix) and id != nil do
    "#{prefix}.#{id}"
  end
end
