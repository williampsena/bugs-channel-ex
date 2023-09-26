defmodule BugsChannel.Events.Event do
  @moduledoc """
  This module is about event struct data.
  """

  alias BugsChannel.Utils.Vex, as: VexUtil

  @doc ~S"""
      iex> event = %BugsChannel.Events.Event{ id: "abc123" }
      iex> BugsChannel.Events.Event.valid?(event)
      true
  """
  use Vex.Struct

  defstruct id: nil,
            project_id: nil,
            platform: nil,
            environment: nil,
            release: nil,
            server_name: nil,
            title: nil,
            body: nil,
            stack_trace: nil,
            kind: nil,
            level: nil,
            origin: nil,
            tags: nil,
            extra_args: nil,
            timestamp: nil

  @doc ~S"""
  Parses event or list

  ## Examples

      iex> BugsChannel.Events.Event.parse(%{ "id" => "abc123", "origin" => "home", "title" => "some error", "body" => "error", "project_id" => 1, "platform" => "elixir", "release" => "git-hash", "server_name" => "foo", "kind" => "error", "environment" => "production", "timestamp" => "2023-09-10T10:42:52.743172Z" })
      {:ok, %BugsChannel.Events.Event{
        id: "abc123",
        project_id: 1,
        platform: "elixir",
        release: "git-hash",
        server_name: "foo",
        title: "some error",
        body: "error",
        kind: "error",
        level: "error",
        origin: "home",
        tags: nil,
        extra_args: nil,
        timestamp: "2023-09-10T10:42:52.743172Z"
      }}

      iex> BugsChannel.Events.Event.parse(%{ "id" => "def456" })
      {:error, ["project_id: must be a number greater than 0", "platform: must have a length of at least 1", "server_name: must have a length of at least 1", "title: must have a length of at least 1", "body: must have a length of at least 1", "kind: must have a length of at least 1"]}
  """
  def parse(params) when is_map(params) do
    event = %BugsChannel.Events.Event{
      id: params["id"],
      project_id: params["project_id"],
      level: params["level"] || "error",
      platform: params["platform"] || "",
      release: params["release"],
      server_name: params["server_name"],
      title: params["title"] || "",
      body: params["body"] || "",
      kind: params["kind"] || "",
      origin: params["origin"] || "home",
      tags: params["tags"],
      extra_args: params["extra_args"],
      timestamp: params["timestamp"] || current_date()
    }

    VexUtil.validate(event, schema())
  end

  defp schema do
    [
      id: [length: [min: 1]],
      project_id: [number: [greater_than: 0]],
      platform: [length: [min: 1]],
      environment: [length: [min: 2, allow_nil: true]],
      release: [length: [min: 1, allow_nil: true]],
      server_name: [length: [min: 1]],
      title: [length: [min: 1]],
      body: [length: [min: 1]],
      stack_trace: [by: [function: &Kernel.is_list/1, allow_nil: true]],
      kind: [length: [min: 1]],
      level: [inclusion: ~w(info warn error fatal)],
      origin: [inclusion: ~w(home sentry)],
      tags: [by: [function: &Kernel.is_list/1, allow_nil: true]],
      extra_args: [by: [function: &Kernel.is_map/1, allow_nil: true]],
      timestamp: [length: [min: 10]]
    ]
  end

  defp current_date() do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end
end
