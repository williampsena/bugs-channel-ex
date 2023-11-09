defmodule Mix.Tasks.Import do
  @moduledoc "Runs the bugs channel API in development mode."
  @shortdoc "Run api"
  @requirements ["app.start"]

  use Mix.Task

  alias BugsChannel.Commands.Import, as: ImportCommand

  @impl Mix.Task
  def run(args) do
    ImportCommand.run(args)
  rescue
    e ->
      Mix.raise(e.message)
  end
end
