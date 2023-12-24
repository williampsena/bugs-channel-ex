import Config

config :bugs_channel, :channels, event_channel: BugsChannel.Channels.Gnat.Channel

config :bugs_channel, :settings, manager: BugsChannel.Settings.Manager

config :bugs_channel, :sentry,
  enabled: true,
  port: 4001

config :bugs_channel, :gnat,
  enabled: true,
  connections_url: ["gnat://localhost:4222?auth_required=false"]

config :bugs_channel,
  event_target: System.get_env("EVENT_TARGET_MODE") || "redis",
  database_mode: System.get_env("DATABASE_MODE") || "dbless",
  config_file: ".config/config.yml"

config :bugs_channel, :mongo,
  connection_url: "mongodb://localhost:27017/bugs-channel",
  pool_size: 3

config :bugs_channel, :redis, connection_url: "redis://localhost:6379/1"
