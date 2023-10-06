import Config

config :bugs_channel, :channels, event_channel: BugsChannel.Channels.Gnat.Channel

config :bugs_channel, :sentry,
  enabled: true,
  port: 4001

config :bugs_channel,
  config_file: ".config/config.yml",
  database_mode: "dbless"

config :bugs_channel, :gnat,
  enabled: true,
  connections_url: ["gnat://localhost:4222?auth_required=false"]
