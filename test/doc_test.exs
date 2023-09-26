defmodule BugsChannel.DocTest do
  use ExUnit.Case

  doctest BugsChannel.Events.Event
  doctest BugsChannel.Plugins.Sentry.Event
  doctest BugsChannel.Utils.Maps
  doctest BugsChannel.Utils.Vex
end
