# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :bugs_channel,
  environment: Mix.env()

config :bugs_channel, :default_channel, max_demand: 1

import_config("#{config_env()}.exs")
