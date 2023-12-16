defmodule Mix.Tasks.DatabaseCleanup do
  @moduledoc "Runs the bugs channel API in development mode."
  @shortdoc "Drop database only for test/dev environment"
  @requirements ["app.start"]

  use Mix.Task

  alias BugsChannel.Commands.DatabaseCleanup, as: DatabaseCleanupCommand

  @impl Mix.Task
  def run(args) do
    DatabaseCleanupCommand.run(args)
  rescue
    e in ArgumentError ->
      Mix.raise(e.message)

    e ->
      Mix.raise(inspect(e))
  end
end
