defmodule BugsChannel.Factories.Event do
  @moduledoc """
  This is the module in charge of the test event structure.
  """

  use ExMachina

  def event_factory do
    %BugsChannel.Repo.Schemas.Event{
      id: "",
      service_id: "1",
      platform: "python",
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
    }
  end
end
