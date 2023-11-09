# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

alias BugsChannel.Repo

config :bugs_channel,
  environment: Mix.env()

config :bugs_channel, :default_channel, max_demand: 1

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000, cleanup_interval_ms: 120_000]}

config :bugs_channel, BugsChannel.Cache,
  primary: [
    gc_interval: :timer.hours(12),
    backend: :shards,
    partitions: 2
  ]

config :bugs_channel,
  nebulex_cache: BugsChannel.Cache

config :bugs_channel, :repos, service: Repo.DBless.Service

config :mongodb_driver,
  migration: [
    path: "migrations",
    otp_app: :bugs_channel,
    topology: :mongo,
    collection: "migrations"
  ]

import_config("#{config_env()}.exs")
