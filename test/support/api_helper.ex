defmodule BugsChannel.Test.Support.ApiHelper do
  @moduledoc """
  This module includes various supports for asserting and dealing with Plug.Conn.
  """

  use ExUnit.Case, only: [assert: 1]

  def assert_conn(%Plug.Conn{} = conn, status_code, body) when is_integer(status_code) do
    assert conn.state == :sent
    assert conn.status == status_code
    assert conn.resp_body == body
  end

  def put_params(conn, params) do
    %{conn | params: params}
  end

  def load_fixture(filename), do: File.read!("test/fixtures/#{filename}")

  def load_json_fixture(filename), do: filename |> load_fixture() |> decode_json!()

  def load_file_and_json_fixture(filename) do
    content = load_fixture(filename)
    {content, decode_json!(content)}
  end

  defp decode_json!(content), do: Jason.decode!(content)
end
