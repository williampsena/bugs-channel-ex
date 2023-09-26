import Config

config :bugs_channel, :channels, event_channel: ChannelMock

config :bugs_channel, :sentry,
  enabled: false,
  port: 4001
