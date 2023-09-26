defmodule BugsChannel.Channels.Gnat.RawEventConsumer do
  @moduledoc """
  The module is in responsible for consuming raw events from NATs.
  """
  use BugsChannel.Channels.Gnat.Consumer

  def dispatch_events(message, _topic) do
    origin = String.to_existing_atom(message["x-origin"] || "home")
    BugsChannel.Events.Producer.enqueue(origin, message)
  end
end
