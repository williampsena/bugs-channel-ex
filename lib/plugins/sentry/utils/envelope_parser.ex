defmodule BugsChannel.Plugins.Sentry.Utils.EnvelopeParser do
  @moduledoc """
  This part of the module is in charge of decoding the sentry envelopes found in the Sentry Elixir Hex Library.
  """

  @behaviour Plug.Parsers

  require Logger

  @impl true
  def init(opts) do
    opts
  end

  @impl true
  def parse(conn, "application", "x-sentry-envelope", _headers, _opts) do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn, length: 1_000_000),
         {:ok, decoded_body} <- decode_body_binary(conn, body) do
      {:ok, decoded_body, conn}
    else
      {:more, _data, conn} ->
        {:error, :too_large, conn}

      {:error, :timeout} ->
        raise Plug.TimeoutError

      {:error, _} ->
        raise Plug.BadRequestError
    end
  end

  @impl true
  def parse(conn, "text", "plain", headers, opts) do
    parse(conn, "application", "x-sentry-envelope", headers, opts)
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp decode_body_binary(conn, binary) when is_binary(binary) do
    body = unzip(conn, binary)

    with {:ok, {raw_headers, raw_items}} <- decode_lines(body),
         {:ok, headers} <- decode_headers(raw_headers),
         {:ok, items} <- decode_items(raw_items) do
      {:ok,
       %{
         "event_id" => headers["event_id"] || nil,
         "items" => items
       }}
    else
      {:error, :missing_header} = error ->
        error

      {:error, _json_error} ->
        {:error, :invalid_envelope}
    end
  end

  # Steps over the item pairs in the envelope body. The item header is decoded
  # first so it can be used to decode the item following it.
  defp decode_items(raw_items) do
    items =
      raw_items
      |> Enum.chunk_every(2, 2, :discard)
      |> Enum.reduce([], fn [k, v], acc ->
        with {:ok, item_header} <- Jason.decode(k),
             {:ok, item} <- decode_item(item_header, v) do
          [item | acc]
        else
          :skip_event -> acc
          {:error, _reason} = error -> throw(error)
        end
      end)

    {:ok, items}
  catch
    {:error, reason} -> {:error, reason}
  end

  defp decode_item(%{"type" => "event"}, data) do
    result = Jason.decode(data)

    case result do
      {:ok, fields} ->
        {:ok,
         %{
           breadcrumbs: fields["breadcrumbs"],
           culprit: fields["culprit"],
           environment: fields["environment"],
           event_id: fields["event_id"],
           __source__: fields["event_source"],
           exception: fields["exception"],
           extra: fields["extra"],
           fingerprint: fields["fingerprint"],
           level: fields["level"],
           message: fields["message"],
           modules: fields["modules"],
           __original_exception__: fields["original_exception"],
           platform: fields["platform"],
           release: fields["release"],
           request: fields["request"],
           server_name: fields["server_name"],
           tags: fields["tags"],
           timestamp: fields["timestamp"],
           user: fields["user"]
         }}

      {:error, e} ->
        {:error, "Failed to decode event item: #{inspect(e)}"}
    end
  end

  defp decode_item(%{"type" => type}, data) do
    Logger.warning("🐞 Event (#{type}) discarded not implemented yet: #{inspect(data)}")

    :skip_event
  end

  defp decode_item(_, _data), do: {:error, "Missing item type header"}

  defp decode_lines(binary) do
    case String.split(binary, "\n", trim: true) do
      [headers | items] ->
        {:ok, {headers, items}}

      _ ->
        {:error, :missing_header}
    end
  end

  defp decode_headers(raw_headers) do
    Jason.decode(raw_headers)
  end

  defp unzip(conn, binary) do
    try do
      if gzip_request?(conn),
        do: :zlib.gunzip(binary),
        else: binary
    rescue
      e ->
        Logger.error(Exception.format(:error, e, __STACKTRACE__))
        binary
    end
  end

  defp gzip_request?(conn), do: {"content-encoding", "gzip"} in conn.req_headers
end
