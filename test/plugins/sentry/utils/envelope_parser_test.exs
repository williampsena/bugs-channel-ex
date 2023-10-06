defmodule BugsChannel.Plugins.Sentry.Utils.EnvelopeParserTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog
  import Mock
  import BugsChannel.Test.Support.FixtureHelper

  alias BugsChannel.Plugins.Sentry.Utils.EnvelopeParser, as: SentryEnvelopeParser

  setup do
    event = load_json_fixture("sentry/event.json")

    event_id = event["event_id"]
    event_item = List.first(event["items"])
    event_item_json = Jason.encode!(event_item)

    encoded_items = [
      [
        ~s({"type": "event", "length": #{byte_size(event_item_json)}}\n),
        event_item_json,
        ?\n
      ]
    ]

    event_binary =
      IO.iodata_to_binary([
        ~s({"event_id":"#{event_id}"}\n)
        | encoded_items
      ])

    event_response = %{
      "event_id" => "ccbf33b5bfd446368efe7ef2113ec78c",
      "items" => [
        %{
          extra: %{"sys.argv" => ["main.py"]},
          message: nil,
          timestamp: "2023-09-10T10:42:52.743172Z",
          request: nil,
          user: nil,
          level: "error",
          modules: %{"pip" => "22.0.2"},
          exception: %{
            "values" => [
              %{
                "mechanism" => %{"handled" => false, "type" => "excepthook"},
                "module" => nil,
                "stacktrace" => %{
                  "frames" => [
                    %{
                      "abs_path" => "/home/foo/main.py",
                      "context_line" => "raise ValueError(\"Error SDK\")",
                      "filename" => "main.py",
                      "function" => "<module>",
                      "in_app" => true,
                      "lineno" => 8,
                      "module" => "__main__",
                      "post_context" => [],
                      "pre_context" => [
                        "sentry_sdk.init(",
                        "    \"http://key@localhost:4001/1\",",
                        "    traces_sample_rate=1.0,",
                        ")",
                        ""
                      ],
                      "vars" => %{
                        "__annotations__" => %{},
                        "__builtins__" => "<module 'builtins' (built-in)>",
                        "__cached__" => "None",
                        "__doc__" => "None",
                        "__file__" => "'/home/foo/main.py'",
                        "__loader__" =>
                          "<_frozen_importlib_external.SourceFileLoader object at 0x7fafa5015e70>",
                        "__name__" => "'__main__'",
                        "__package__" => "None",
                        "__spec__" => "None",
                        "sentry_sdk" =>
                          "<module 'sentry_sdk' from '/home/foo/.local/lib/python3.10/site-packages/sentry_sdk/__init__.py'>"
                      }
                    }
                  ]
                },
                "type" => "ValueError",
                "value" => "Error SDK"
              }
            ]
          },
          tags: nil,
          event_id: "ccbf33b5bfd446368efe7ef2113ec78c",
          __original_exception__: nil,
          __source__: nil,
          breadcrumbs: %{"values" => []},
          culprit: nil,
          environment: "production",
          fingerprint: nil,
          platform: "python",
          release: nil,
          server_name: "foo"
        }
      ]
    }

    [
      event_id: event_id,
      event_binary: event_binary,
      event_response: event_response
    ]
  end

  test "initialize plug" do
    assert SentryEnvelopeParser.init(foo: "bar") == [foo: "bar"]
  end

  describe "parse/5" do
    test "when content is unsupported" do
      conn = conn(:post, "/", "")

      assert SentryEnvelopeParser.parse(conn, "text", "plain", [], []) ==
               {:next, conn}
    end

    test "when content raises bad format" do
      event_binary_wrong =
        IO.iodata_to_binary([
          ~s(vai)
        ])

      conn =
        :post
        |> conn("/1", event_binary_wrong)
        |> put_resp_content_type("application/x-sentry-envelope")

      assert_raise Plug.BadRequestError,
                   "could not process the request due to client error",
                   fn ->
                     SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], [])
                   end
    end

    test "when content is too large" do
      event_binary_wrong =
        IO.iodata_to_binary([
          ~s(too large)
        ])

      conn =
        :post
        |> conn("/1", event_binary_wrong)
        |> put_resp_content_type("application/x-sentry-envelope")

      with_mock(Plug.Conn, [:passthrough],
        read_body: fn conn, [length: 1_000_000] -> {:more, "", conn} end
      ) do
        assert SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], []) ==
                 {:error, :too_large, conn}
      end
    end

    test "when plug respond timeout" do
      event_binary_wrong =
        IO.iodata_to_binary([
          ~s(too large)
        ])

      conn =
        :post
        |> conn("/1", event_binary_wrong)
        |> put_resp_content_type("application/x-sentry-envelope")

      with_mock(Plug.Conn, [:passthrough],
        read_body: fn _conn, [length: 1_000_000] -> {:error, :timeout} end
      ) do
        assert_raise Plug.TimeoutError,
                     "timeout while waiting for request data",
                     fn ->
                       SentryEnvelopeParser.parse(
                         conn,
                         "application",
                         "x-sentry-envelope",
                         [],
                         []
                       )
                     end
      end
    end

    test "when content there is no header" do
      event_binary_no_header =
        IO.iodata_to_binary([])

      conn =
        :post
        |> conn("/1", event_binary_no_header)
        |> put_resp_content_type("application/x-sentry-envelope")

      assert_raise Plug.BadRequestError,
                   "could not process the request due to client error",
                   fn ->
                     SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], [])
                   end
    end

    test "when content has items with invalid type", %{event_id: event_id} do
      event_item_json = "{wrong_json}"

      encoded_items = [
        [
          ~s({"type": "wrong", "length": #{byte_size(event_item_json)}}\n),
          event_item_json,
          ?\n
        ]
      ]

      event_binary_wrong =
        IO.iodata_to_binary([
          ~s({"event_id":"#{event_id}"}\n)
          | encoded_items
        ])

      conn =
        :post
        |> conn("/1", event_binary_wrong)
        |> put_resp_content_type("application/x-sentry-envelope")

      assert capture_log(fn ->
               SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], [])
             end) =~ "🐞 Event (wrong) discarded not implemented yet: \"{wrong_json}\""
    end

    test "when content there is missing type header", %{event_id: event_id} do
      event_item_json = "{wrong_json}"

      encoded_items = [
        [
          ~s({"length": #{byte_size(event_item_json)}}\n),
          event_item_json,
          ?\n
        ]
      ]

      event_binary_wrong =
        IO.iodata_to_binary([
          ~s({"event_id":"#{event_id}"}\n)
          | encoded_items
        ])

      conn =
        :post
        |> conn("/1", event_binary_wrong)
        |> put_resp_content_type("application/x-sentry-envelope")

      assert_raise Plug.BadRequestError,
                   "could not process the request due to client error",
                   fn ->
                     SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], [])
                   end
    end

    test "when content there is an error with item encoding", %{event_id: event_id} do
      event_item_json = "{wrong_json}"

      encoded_items = [
        [
          ~s({"type": "event", "length": #{byte_size(event_item_json)}}\n),
          event_item_json,
          ?\n
        ]
      ]

      event_binary =
        IO.iodata_to_binary([
          ~s({"event_id":"#{event_id}"}\n)
          | encoded_items
        ])

      conn =
        :post
        |> conn("/1", event_binary)
        |> put_resp_content_type("application/x-sentry-envelope")

      assert_raise Plug.BadRequestError,
                   "could not process the request due to client error",
                   fn ->
                     SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], [])
                   end
    end

    test "when content is not compressed", %{
      event_binary: event_binary,
      event_response: event_response
    } do
      conn =
        :post
        |> conn("/1", event_binary)
        |> put_resp_content_type("application/x-sentry-envelope")

      {:ok, decoded_body, _} =
        SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], [])

      assert decoded_body == event_response
    end

    test "when content is not compressed but there is content-encoding(gzip)", %{
      event_binary: event_binary,
      event_response: event_response
    } do
      conn =
        :post
        |> conn("/1", event_binary)
        |> put_resp_content_type("application/x-sentry-envelope")
        |> put_req_header("content-encoding", "gzip")

      {:ok, decoded_body, _} =
        SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], [])

      assert decoded_body == event_response
    end

    test "when content is compressed", %{
      event_binary: event_binary,
      event_response: event_response
    } do
      event_binary = :zlib.gzip(event_binary)

      conn =
        :post
        |> conn("/1", event_binary)
        |> put_resp_content_type("application/x-sentry-envelope")
        |> put_req_header("content-encoding", "gzip")

      {:ok, decoded_body, _} =
        SentryEnvelopeParser.parse(conn, "application", "x-sentry-envelope", [], [])

      assert decoded_body == event_response
    end
  end
end
