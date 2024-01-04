defmodule BugsChannel.Repo.EventTest do
  use ExUnit.Case

  import BugsChannel.Factories.Event
  import Mox

  alias BugsChannel.Repo, as: Repo
  alias BugsChannel.Repo.Query.QueryCursor

  setup :verify_on_exit!

  setup do
    event = build(:event)

    {:ok, inserted_event} =
      Repo.Event.insert(event)

    [event: event, event_id: "#{inserted_event.id}"]
  end

  describe "get/1" do
    test "when a event is not found" do
      assert Repo.Event.get("657529b00000000000000000") == nil
    end

    test "when a event is found", %{event_id: event_id} do
      assert match?(
               %BugsChannel.Repo.Schemas.Event{
                 platform: "python",
                 body: "Bar messages",
                 environment: nil,
                 extra_args: nil,
                 inserted_at: nil,
                 kind: "error",
                 level: "error",
                 meta_id: nil,
                 origin: :sentry,
                 release: nil,
                 server_name: nil,
                 service_id: "1",
                 stack_trace: [%{"type" => "FooException", "value" => "Bar messages"}],
                 tags: [],
                 title: "FooException: Bar messages",
                 updated_at: nil
               },
               Repo.Event.get(event_id)
             )
    end
  end

  describe "list_by_service/1" do
    test "when there is no events" do
      assert Repo.Event.list_by_service("657529b00000000000000000") ==
               %BugsChannel.Repo.Query.PagedResults{
                 data: [],
                 local: %{empty: true},
                 meta: %{offset: 0, limit: 25, page: 0, count: 0}
               }
    end

    test "when a event is found", %{event: event} do
      events = Repo.Event.list_by_service(event.service_id)
      count = Kernel.length(events.data)

      assert events.meta == %{limit: 25, offset: 0, page: 0, count: count}

      assert match?(
               %BugsChannel.Repo.Schemas.Event{
                 platform: "python",
                 body: "Bar messages",
                 environment: nil,
                 extra_args: nil,
                 inserted_at: nil,
                 kind: "error",
                 level: "error",
                 meta_id: nil,
                 origin: :sentry,
                 release: nil,
                 server_name: nil,
                 service_id: "1",
                 stack_trace: [%{"type" => "FooException", "value" => "Bar messages"}],
                 tags: [],
                 title: "FooException: Bar messages",
                 updated_at: nil
               },
               List.first(events.data)
             )
    end
  end

  describe "list/1" do
    test "when there is no events" do
      assert Repo.Event.list(%{"platform" => "cobol"}) == %BugsChannel.Repo.Query.PagedResults{
               data: [],
               local: %{empty: true},
               meta: %{offset: 0, limit: 25, page: 0, count: 0}
             }
    end

    test "when a event is found", %{event: event} do
      events = Repo.Event.list(%{"service_id" => "#{event.service_id}", "platform" => "python"})
      count = Kernel.length(events.data)

      assert events.local == %{
               empty: false,
               next_page: %QueryCursor{offset: 25, limit: 25, page: 1}
             }

      assert events.meta == %{limit: 25, offset: 0, page: 0, count: count}

      assert match?(
               %BugsChannel.Repo.Schemas.Event{
                 platform: "python",
                 body: "Bar messages",
                 environment: nil,
                 extra_args: nil,
                 inserted_at: nil,
                 kind: "error",
                 level: "error",
                 meta_id: nil,
                 origin: :sentry,
                 release: nil,
                 server_name: nil,
                 service_id: "1",
                 stack_trace: [%{"type" => "FooException", "value" => "Bar messages"}],
                 tags: [],
                 title: "FooException: Bar messages",
                 updated_at: nil
               },
               List.first(events.data)
             )
    end

    test "when there multiple events and cursor", %{event: event} do
      environment = "multiple_events"
      filters = %{"environment" => environment}
      event = Map.put(event, :environment, environment)

      Enum.each(1..25, fn _ -> {:ok, _} = Repo.Event.insert(event) end)

      events = Repo.Event.list(filters)
      assert events.meta == %{limit: 25, offset: 0, page: 0, count: 25}

      assert match?(
               %BugsChannel.Repo.Schemas.Event{
                 platform: "python",
                 body: "Bar messages",
                 environment: "multiple_events",
                 extra_args: nil,
                 inserted_at: nil,
                 kind: "error",
                 level: "error",
                 meta_id: nil,
                 origin: :sentry,
                 release: nil,
                 server_name: nil,
                 service_id: "1",
                 stack_trace: [%{"type" => "FooException", "value" => "Bar messages"}],
                 tags: [],
                 title: "FooException: Bar messages",
                 updated_at: nil
               },
               List.first(events.data)
             )

      assert Repo.Event.list(filters, events.local.next_page) ==
               %BugsChannel.Repo.Query.PagedResults{
                 data: [],
                 meta: %{count: 0, offset: 25, limit: 25, page: 1},
                 local: %{empty: true}
               }
    end
  end

  describe "insert/1" do
    test "when a event is valid" do
      event = build(:event)
      assert {:ok, inserted_event} = Repo.Event.insert(event)
      assert match?(%BugsChannel.Repo.Schemas.Event{}, inserted_event)
      refute is_nil(inserted_event.id)
    end
  end
end
