defmodule BugsChannel.Channels.Gnat.EventConsumer do
  @moduledoc """
  The module is in responsible for consuming events from NATs.
  """
  use BugsChannel.Channels.Gnat.Consumer

  def dispatch_events(_message, topic) do
    Logger.info("Dead letter (#{topic}) not implemented yet.")

    :ok
  end
end
