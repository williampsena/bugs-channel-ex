defmodule BugsChannel.DocTest do
  use ExUnit.Case

  doctest BugsChannel.Plugins.Sentry.Event
  doctest BugsChannel.Utils.ConfigBuilder
  doctest BugsChannel.Utils.Maps
  doctest BugsChannel.Utils.Ecto
  doctest BugsChannel.Utils.ConnectionParamsBuilder

  doctest BugsChannel.Applications.Gnat
  doctest BugsChannel.Applications.Mongo
  doctest BugsChannel.Applications.Sentry
  doctest BugsChannel.Applications.Settings

  doctest BugsChannel.Repo.Parsers.Base
  doctest BugsChannel.Repo.Parsers.Service
  doctest BugsChannel.Repo.Parsers.Event
end
