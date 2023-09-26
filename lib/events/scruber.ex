defmodule BugsChannel.Events.Scrubber do
  @moduledoc """
  This module is in charge of masking any sensitive data.
  """

  @credit_card_regex ~r/^(?:\d[ -]*?){13,16}$/
  @scrubbed_value "*********"

  def scrub_map(map) when is_map(map) do
    scrub_map(map, scrubbed_param_keys())
  end

  def scrub_map(map, scrubbed_keys) when is_map(map) do
    Map.new(map, fn {key, value} ->
      value =
        cond do
          "#{key}" in scrubbed_keys -> @scrubbed_value
          is_binary(value) and value =~ @credit_card_regex -> @scrubbed_value
          is_struct(value) -> value |> Map.from_struct() |> scrub_map(scrubbed_keys)
          is_map(value) -> scrub_map(value, scrubbed_keys)
          is_list(value) -> scrub_list(value, scrubbed_keys)
          true -> value
        end

      {key, value}
    end)
  end

  def scrub_list(list) when is_list(list) do
    scrub_list(list, scrubbed_param_keys())
  end

  def scrub_list(list, scrubbed_keys) when is_list(list) do
    Enum.map(list, fn value ->
      cond do
        is_struct(value) -> value |> Map.from_struct() |> scrub_map(scrubbed_keys)
        is_map(value) -> scrub_map(value, scrubbed_keys)
        is_list(value) -> scrub_list(value, scrubbed_keys)
        true -> value
      end
    end)
  end

  def scrub_headers(%Plug.Conn{} = conn) do
    scrub_headers(%Plug.Conn{} = conn, scrubbed_header_keys())
  end

  def scrub_headers(%Plug.Conn{} = conn, scrubbed_keys) do
    conn.req_headers
    |> Map.new()
    |> Map.drop(scrubbed_keys)
  end

  defp scrubbed_param_keys, do: config()[:param_keys]
  defp scrubbed_header_keys, do: config()[:header_keys]
  defp config, do: Application.get_env(:bugs_channel, :scrubber)
end
