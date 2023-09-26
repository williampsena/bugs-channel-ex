import Config

config :bugs_channel, :channels, event_channel: BugsChannel.Channels.Gnat.Channel

config :bugs_channel, :sentry,
  enabled: true,
  port: 4001
