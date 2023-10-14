defmodule BugsChannel.DocTest do
  use ExUnit.Case

  doctest BugsChannel.Plugins.Sentry.Event
  doctest BugsChannel.Utils.Maps
  doctest BugsChannel.Utils.Ecto
  doctest BugsChannel.Utils.ConnectionParamsBuilder

  doctest BugsChannel.Applications.Gnat
  doctest BugsChannel.Applications.Mongo
  doctest BugsChannel.Applications.Sentry
  doctest BugsChannel.Applications.Settings
end
