defmodule BugsChannel.DocTest do
  use ExUnit.Case

  doctest BugsChannel

  doctest BugsChannel.Plugins.Sentry.Event
  doctest BugsChannel.Utils.ConfigBuilder
  doctest BugsChannel.Utils.Maps
  doctest BugsChannel.Utils.Ecto
  doctest BugsChannel.Utils.ConnectionParamsBuilder

  doctest BugsChannel.Applications.Channels
  doctest BugsChannel.Applications.Gnat
  doctest BugsChannel.Applications.Mongo
  doctest BugsChannel.Applications.Redis
  doctest BugsChannel.Applications.Sentry
  doctest BugsChannel.Applications.Settings
  doctest BugsChannel.Applications.Api

  doctest BugsChannel.Repo.Base
  doctest BugsChannel.Repo.Parsers.Base
  doctest BugsChannel.Repo.Parsers.Service
  doctest BugsChannel.Repo.Parsers.Event
  doctest BugsChannel.Repo.Query.QueryCursor
  doctest BugsChannel.Repo.Query.PagedResults

  doctest BugsChannel.Api.Views.PagedResults
  doctest BugsChannel.Api.Views.Error
end
