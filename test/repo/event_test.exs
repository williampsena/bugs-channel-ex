defmodule BugsChannel.Repo.EventTest do
  use ExUnit.Case

  import BugsChannel.Factories.Event
  import Mox

  alias BugsChannel.Repo, as: Repo

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
                 meta: %{offset: 0, limit: 25, page: 0}
               }
    end

    test "when a event is found", %{event: event} do
      events = Repo.Event.list_by_service(event.service_id)

      assert events.meta == %{limit: 25, offset: 0, page: 0}

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
               meta: %{offset: 0, limit: 25, page: 0}
             }
    end

    test "when a event is found", %{event: event} do
      events = Repo.Event.list(%{"service_id" => "#{event.service_id}", "platform" => "python"})

      assert events.meta == %{limit: 25, offset: 0, page: 0}

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

  describe "insert/1" do
    test "when a event is valid" do
      event = build(:event)
      assert {:ok, inserted_event} = Repo.Event.insert(event)
      assert match?(%BugsChannel.Repo.Schemas.Event{}, inserted_event)
      refute is_nil(inserted_event.id)
    end
  end
end
