defmodule BugsChannel.Plugins.Sentry.Event do
  @moduledoc """
  This module provides a plugin to support sentry events.
  """

  require Logger

  alias BugsChannel.Repo.Schemas.Event, as: BugsChannelEvent

  @title_max_len 100

  @doc ~S"""
  Parse a valid event

  ## Examples

      iex> BugsChannel.Plugins.Sentry.Event.parse_to_event(%{ "event_id" => "1", "project" => 1, "items" => [ %{ "message" => "foo" } ] })
      {:ok, [%BugsChannel.Repo.Schemas.Event{
        id: "1",
        service_id: 1,
        platform: nil,
        environment: nil,
        release: nil,
        server_name: nil,
        title: "foo",
        body: "foo",
        stack_trace: nil,
        kind: "event",
        level: "error",
        origin: :sentry,
        tags: [],
        extra_args: nil
      }]}

      iex> event_id = "00000000-0000-0000-0000-000000000000"
      iex> BugsChannel.Plugins.Sentry.Event.parse_to_event(%{ "event_id" => event_id, "project" => 1, "items" => [ %{"exception" => %{"values" => [ %{"type" => "FooException", "value" => "Bar messages" } ] } } ] })
      {:ok, [%BugsChannel.Repo.Schemas.Event{
        id: "00000000-0000-0000-0000-000000000000",
        service_id: 1,
        platform: nil,
        environment: nil,
        release: nil,
        server_name: nil,
        title: "FooException: Bar messages",
        body: "Bar messages",
        stack_trace: [%{"type" => "FooException", "value" => "Bar messages"}],
        kind: "error",
        level: "error",
        origin: :sentry,
        tags: [],
        extra_args: nil
      }]}

      iex> BugsChannel.Plugins.Sentry.Event.parse_to_event(nil)
      {:error, :invalid_sentry_event}

      iex> BugsChannel.Plugins.Sentry.Event.parse_to_event(%{ "event_id" => "foo", "service" => "bar" })
      {:error, :invalid_sentry_event}

  """
  def parse_to_event(nil), do: invalid_sentry_event()

  def parse_to_event(event) when is_map(event) do
    try do
      events =
        Enum.map(event["items"], fn sentry_event ->
          %{title: title, body: body, kind: kind} = extract_event_data(sentry_event)

          params = %{
            "id" => "#{event["event_id"]}",
            "service_id" => event["project"],
            "platform" => sentry_event["platform"],
            "environment" => sentry_event["environment"],
            "release" => sentry_event["release"],
            "server_name" => sentry_event["server_name"],
            "stack_trace" => get_in(sentry_event, ~w(exception values)),
            "title" => title,
            "body" => body,
            "level" => sentry_event["level"] || "error",
            "kind" => kind,
            "origin" => :sentry,
            "tags" => sentry_event["tags"] || [],
            "extra_args" => sentry_event["extra"],
            "inserted_at" => sentry_event["timestamp"]
          }

          with {:ok, event} <- BugsChannelEvent.parse(params) do
            event
          end
        end)

      {:ok, events}
    rescue
      e ->
        Logger.error(Exception.format(:error, e, __STACKTRACE__))
        invalid_sentry_event()
    end
  end

  defp extract_event_data(%{"message" => message}) when is_binary(message) do
    %{title: message |> String.slice(0..@title_max_len), body: message, kind: "event"}
  end

  defp extract_event_data(%{"exception" => %{"values" => [exception | []]}}) do
    %{
      title: "#{exception["type"]}: #{exception["value"]}" |> String.slice(0..@title_max_len),
      body: exception["value"],
      kind: "error"
    }
  end

  defp invalid_sentry_event(), do: {:error, :invalid_sentry_event}
end
