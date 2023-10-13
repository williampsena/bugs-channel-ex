import Config

config :bugs_channel, :channels, event_channel: ChannelMock

config :bugs_channel, :settings, manager: SettingsManagerMock

config :bugs_channel, :sentry,
  enabled: false,
  port: 4001

config :bugs_channel,
  nebulex_cache: BugsChannel.TestCache

config :bugs_channel, :config_file, "test/fixtures/settings/config.yml"
