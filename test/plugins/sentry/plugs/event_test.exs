defmodule BugsChannel.Plugins.Sentry.Plugs.EventTest do
  use ExUnit.Case
  use Plug.Test

  import Mox
  import BugsChannel.Test.Support.ApiHelper
  import BugsChannel.Test.Support.FixtureHelper
  import BugsChannel.Mocks.ChannelMocks

  alias BugsChannel.Plugins.Sentry.Plugs.Event, as: SentryEventPlug

  setup :verify_on_exit!

  setup do
    event_json = load_fixture("sentry/event.json")

    [
      event_json: event_json,
      event: Jason.decode!(event_json)
    ]
  end

  test "initialize plug" do
    assert SentryEventPlug.init(foo: "bar") == [foo: "bar"]
  end

  test "test route not found" do
    conn =
      :get
      |> conn("/", "")
      |> SentryEventPlug.call([])

    assert_conn(conn, 404, "Oops! 👀")
  end

  describe "post events" do
    setup context do
      event = context[:event]
      event_id = event["event_id"]
      raw_event_topic = "raw-event"
      topic = "#{raw_event_topic}.#{event_id}"

      raw_event_json = event |> Map.put("x-origin", "sentry") |> Jason.encode!()

      [
        event_id: event_id,
        topic: topic,
        raw_event_topic: raw_event_topic,
        raw_event_json: raw_event_json
      ]
    end

    test "when is valid event", %{
      event_id: event_id,
      event: event,
      event_json: event_json,
      topic: topic,
      raw_event_topic: raw_event_topic,
      raw_event_json: raw_event_json
    } do
      expect_channel_build_topic(event_id, raw_event_topic)
      expect_channel_publish(topic, raw_event_json)

      conn =
        :post
        |> conn("/api/1/envelope", event_json)
        |> put_resp_content_type("application/x-sentry-envelope")
        |> put_params(event)
        |> SentryEventPlug.call([])

      assert_conn(conn, 200, %{"event_id" => event_id})
    end

    test "when skip a event", %{event: event} do
      event = Map.put(event, "event_id", nil)
      event_json = Jason.encode!(event)

      conn =
        :post
        |> conn("/api/1/envelope", event_json)
        |> put_resp_content_type("application/x-sentry-envelope")
        |> put_params(event)
        |> SentryEventPlug.call([])

      assert_conn(conn, 204, "")
    end

    test "when payload event is invalid" do
      conn =
        :post
        |> conn("/", "")
        |> put_resp_content_type("application/x-sentry-envelope")
        |> put_params("")
        |> SentryEventPlug.call([])

      assert_conn(conn, 422, Jason.encode!(%{"error" => "Payload is invalid"}))
    end

    test "when faced by an error pushing event", %{
      event_id: event_id,
      event: event,
      event_json: event_json,
      topic: topic,
      raw_event_topic: raw_event_topic,
      raw_event_json: raw_event_json
    } do
      expect_channel_build_topic(event_id, raw_event_topic)
      expect_channel_publish_error(topic, raw_event_json)

      conn =
        :post
        |> conn("/api/1/envelope", event_json)
        |> put_resp_content_type("application/x-sentry-envelope")
        |> put_params(event)
        |> SentryEventPlug.call([])

      assert_conn(conn, 500, "Something went wrong 😦")
    end
  end
end
