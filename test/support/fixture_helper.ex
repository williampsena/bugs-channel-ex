defmodule BugsChannel.Test.Support.FixtureHelper do
  @moduledoc """
  This module includes various supports for loading fixtures
  """

  def load_fixture(filename), do: File.read!("test/fixtures/#{filename}")

  def load_json_fixture(filename), do: filename |> load_fixture() |> decode_json!()

  def load_file_and_json_fixture(filename) do
    content = load_fixture(filename)
    {content, decode_json!(content)}
  end

  defp decode_json!(content), do: Jason.decode!(content)
end
