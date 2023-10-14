defmodule BugsChannel.Applications.Gnat do
  @moduledoc """
  This is the gnat application module in charge of startup processes.
  """

  require Logger

  alias BugsChannel.Channels.Gnat.{EventConsumer, RawEventConsumer}
  alias BugsChannel.Utils.ConnectionParamsBuilder

  @doc ~S"""
  Starts gnat gen server supervisor

  ## Examples

      iex> BugsChannel.Applications.Gnat.start([ enabled: true, connections_url: ["gnat://localhost:4222?auth_required=false"] ])
      [{Gnat.ConnectionSupervisor, %{name: :gnat, connection_settings: [%{port: 4222, host: "localhost", auth_required: false}], backoff_period: 4000}}, %{id: :"raw-event.*", start: {Gnat.ConsumerSupervisor, :start_link, [%{module: BugsChannel.Channels.Gnat.RawEventConsumer, shutdown: 30000, connection_name: :gnat, subscription_topics: [%{topic: "raw-event.*", queue_group: "RawEvents"}]}]}}, %{id: :"event.*", start: {Gnat.ConsumerSupervisor, :start_link, [%{module: BugsChannel.Channels.Gnat.EventConsumer, shutdown: 30000, connection_name: :gnat, subscription_topics: [%{topic: "event.*", queue_group: "Events"}]}]}}]
  """
  def start(config \\ nil) do
    config = config || gnat_config()

    if config[:enabled],
      do: do_start(config),
      else: []
  end

  defp do_start(config) when is_list(config) do
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

  defp gnat_config(), do: Application.get_env(:bugs_channel, :gnat)
end
