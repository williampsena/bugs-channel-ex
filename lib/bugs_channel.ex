defmodule BugsChannel do
  @moduledoc """
  This is the application module in charge of starting processes.
  """
  use Application
  use Supervisor

  require Logger

  alias BugsChannel.Utils.ConnectionParamsBuilder

  def init(args) do
    args
  end

  def start(_type, _args) do
    children =
      [
        {Bandit, plug: BugsChannel.Router, port: server_port()}
      ] ++
        maybe_build_config_file_agent() ++
        maybe_build_process(:sentry, &build_sentry_proxy/1) ++
        maybe_build_process(:gnat, &build_gnat/1) ++
        build_channels()

    opts = [strategy: :one_for_one, name: BugsChannel.Supervisor]

    Logger.info("🐛 Starting application...")

    Supervisor.start_link(children, opts)
  end

  defp maybe_build_process(key, child_process) do
    config = config(key)

    if config[:enabled],
      do: child_process.(config),
      else: []
  end

  defp build_sentry_proxy(config) do
    Logger.info("🐜 Starting Sentry Plugin Router...")

    [{Bandit, plug: BugsChannel.Plugins.Sentry.Router, port: config[:port]}]
  end

  defp build_gnat(config) do
    alias BugsChannel.Channels.Gnat.{EventConsumer, RawEventConsumer}

    Logger.info("👮 Starting NATs supervisor...")

    connection_settings =
      Enum.reduce(
        config[:connections_url] || [],
        [],
        fn config, acc ->
          case ConnectionParamsBuilder.from_url(config, auth_required: :boolean) do
            {"gnat", connection_config} ->
              acc ++ [connection_config]

            _ ->
              acc
          end
        end
      )

    if connection_settings == [],
      do: raise(ArgumentError, message: "invalid gnat connections")

    gnat_supervisor_config = %{
      name: :gnat,
      backoff_period: 4_000,
      connection_settings: connection_settings
    }

    [
      {Gnat.ConnectionSupervisor, gnat_supervisor_config},
      build_gnat_consumer(RawEventConsumer, "raw-event.*", "RawEvents"),
      build_gnat_consumer(EventConsumer, "event.*", "Events")
    ]
  end

  defp build_gnat_consumer(consumer, topic, queue_group) do
    Supervisor.child_spec(
      {Gnat.ConsumerSupervisor,
       %{
         connection_name: :gnat,
         module: consumer,
         subscription_topics: [
           %{topic: topic, queue_group: queue_group}
         ],
         shutdown: 30_000
       }},
      id: String.to_atom(topic)
    )
  end

  defp build_channels() do
    Logger.info("⚙️ Starting GenStages...")

    [
      {BugsChannel.Events.Producer, []}
    ]
  end

  defp maybe_build_config_file_agent() do
    if dbless_mode?() do
      Logger.info("📝 Starting Dbless agent...")
      [{BugsChannel.Settings.Manager, []}]
    else
      []
    end
  end

  defp config(key), do: Application.get_env(:bugs_channel, key)
  defp server_port(), do: config(:server_port)
  defp dbless_mode?(), do: config(:database_mode) == "dbless"
end
