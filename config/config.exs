# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :bugs_channel,
  environment: Mix.env()

config :bugs_channel, :default_channel, max_demand: 1

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000, cleanup_interval_ms: 120_000]}

import_config("#{config_env()}.exs")
