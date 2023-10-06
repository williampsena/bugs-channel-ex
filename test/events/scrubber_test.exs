defmodule BugsChannel.Events.ScrubberTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import BugsChannel.Test.Support.FixtureHelper

  alias BugsChannel.Events.Scrubber

  defmodule SecretStruct do
    defstruct secret: ""
  end

  @scrubbed "*********"

  describe "scrub_map" do
    setup do
      sentry_event = load_json_fixture("sentry/event_with_sensitive_data.json")

      fake_event =
        %{
          "name" => "foo",
          "keys" => [1, 2, 3],
          "password" => "bar",
          "credit_card" => "371449635398431",
          "list" => [%{"passwd" => "bar"}],
          "map" => %{"secret" => "foo"},
          "struct" => %SecretStruct{secret: "foo"}
        }

      [sentry_event: sentry_event, fake_event: fake_event]
    end

    test "scrub post with sensitive data in all value types", %{fake_event: fake_event} do
      assert match?(
               %{
                 "name" => "foo",
                 "keys" => [1, 2, 3],
                 "credit_card" => "*********",
                 "list" => [%{"passwd" => "*********"}],
                 "map" => %{"secret" => "*********"},
                 "password" => "*********",
                 "struct" => %{secret: "*********"}
               },
               Scrubber.scrub_map(fake_event)
             )
    end

    test "scrub post with sensitive with custom keys", %{fake_event: fake_event} do
      assert match?(
               %{
                 "credit_card" => "*********",
                 "keys" => "*********",
                 "list" => [%{"passwd" => "bar"}],
                 "map" => %{"secret" => "foo"},
                 "name" => "foo",
                 "password" => "*********",
                 "struct" => %{secret: "foo"}
               },
               Scrubber.scrub_map(fake_event, ["password", "keys"])
             )
    end

    test "scrub post event request", %{sentry_event: sentry_event} do
      assert match?(
               %{
                 "items" => [
                   %{
                     "extra" => %{"passwd" => @scrubbed},
                     "password" => @scrubbed,
                     "exception" => %{
                       "values" => [
                         %{
                           "stacktrace" => %{
                             "frames" => [
                               %{"secret" => @scrubbed, "vars" => %{"secret" => @scrubbed}}
                             ]
                           }
                         }
                       ]
                     }
                   }
                 ]
               },
               Scrubber.scrub_map(sentry_event)
             )
    end

    test "scrub post event request without sensitive data" do
      event = load_json_fixture("sentry/event.json")

      refute match?(
               %{
                 "items" => [
                   %{
                     "extra" => %{"password" => @scrubbed},
                     "password" => @scrubbed,
                     "exception" => %{
                       "values" => [
                         %{
                           "stacktrace" => %{
                             "frames" => [%{"vars" => %{"secret" => @scrubbed}}]
                           }
                         }
                       ]
                     }
                   }
                 ]
               },
               Scrubber.scrub_map(event)
             )
    end
  end

  describe "scrub_list" do
    setup do
      fake_events = [
        %{
          "name" => "foo",
          "keys" => [1, 2, 3],
          "password" => "bar",
          "credit_card" => "371449635398431",
          "list" => [%{"passwd" => "bar"}],
          "map" => %{"secret" => "foo"},
          "struct" => %SecretStruct{secret: "foo"}
        }
      ]

      [fake_events: fake_events]
    end

    test "scrub post with sensitive data in all value types", %{fake_events: fake_events} do
      assert match?(
               [
                 %{
                   "name" => "foo",
                   "keys" => [1, 2, 3],
                   "credit_card" => "*********",
                   "list" => [%{"passwd" => "*********"}],
                   "map" => %{"secret" => "*********"},
                   "password" => "*********",
                   "struct" => %{secret: "*********"}
                 }
               ],
               Scrubber.scrub_list(fake_events)
             )
    end

    test "scrub post with sensitive data and custom keys", %{fake_events: fake_events} do
      assert match?(
               [
                 %{
                   "credit_card" => "*********",
                   "keys" => [1, 2, 3],
                   "list" => [%{"passwd" => "*********"}],
                   "map" => %{"secret" => "*********"},
                   "name" => "foo",
                   "password" => "bar",
                   "struct" => %{secret: "*********"}
                 }
               ],
               Scrubber.scrub_list(fake_events, ["secret", "passwd"])
             )
    end
  end

  describe "scrub_headers" do
    setup do
      conn =
        conn(:post, "/", "")
        |> put_resp_content_type("application/json")
        |> put_req_header("user", "foo")
        |> put_req_header("profile", "bar")
        |> put_req_header("x-app", "foo-bar")
        |> put_req_header("authorization", "Bearer Token")
        |> put_req_header("authentication", "secret")
        |> put_req_header("cookie", "chips")

      [conn: conn]
    end

    test "scrub headers with sensitive data", %{conn: conn} do
      assert match?(
               %{"profile" => "bar", "user" => "foo", "x-app" => "foo-bar"},
               Scrubber.scrub_headers(conn)
             )
    end

    test "scrub headers with sensitive data and custom keys", %{conn: conn} do
      assert match?(
               %{"x-app" => "foo-bar"},
               Scrubber.scrub_headers(conn, ["profile|user|authorization|authentication|cookie"])
             )
    end
  end
end
