# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config
import BugsChannel.ConfigBuilder

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  level: String.to_atom(System.get_env("LOG_LEVEL") || "info")

config :bugs_channel,
  server_port: String.to_integer(System.get_env("PORT") || "4000")

if System.get_env("MIX_ENV") == "prod" do
  config :bugs_channel, :sentry,
    enabled: System.get_env("SENTRY_ENABLED") == "true",
    port: String.to_integer(System.get_env("SENTRY_PORT") || "4001")

  config :bugs_channel,
    environment: String.to_atom(System.get_env("MIX_ENV") || "development")
end

config :bugs_channel, :gnat,
  enabled: System.get_env("GNATS_CHANNEL") == "nats",
  host: System.get_env("GNATS_HOST") || "localhost",
  port: String.to_integer(System.get_env("GNATS_PORT") || "4222"),
  username: System.get_env("GNATS_USERNAME"),
  password: System.get_env("GNATS_PASSWORD"),
  auth_required: System.get_env("GNATS_AUTH_DISABLED") !== "true"

config :bugs_channel, :scrubber,
  mask_keys: list_from_env("SCRUBBER_MASK_KEYS", "user|email|apikey"),
  param_keys: list_from_env("SCRUBBER_PARAM_KEYS", "password|passwd|secret"),
  header_keys: list_from_env("SCRUBBER_HEADER_KEYS", "authorization|authentication|cookie")
