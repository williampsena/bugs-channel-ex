defmodule BugsChannel.Plugs.RateLimiter do
  @moduledoc """
  This plug is in responsible for limiting requests
  """

  require Logger

  import Plug.Conn
  import BugsChannel.Plugs.Api

  def init(opts) do
    (opts || [])
    |> Keyword.put_new(:key, "_")
    |> Keyword.put_new(:by, [:header, "x-api-key"])
    |> Keyword.put_new(:ttl, rate_limit_ttl())
    |> Keyword.put_new(:limit, rate_limit_request())
  end

  def call(conn, opts) do
    value = fetch_value(conn, opts[:by])
    key = opts[:key]

    case Hammer.check_rate("#{key}:#{value}", opts[:ttl], opts[:limit]) do
      {:allow, _count} ->
        conn

      {:deny, limit} ->
        conn |> send_too_many_requests_resp(limit) |> halt()
    end
  end

  defp fetch_value(conn, [:assigns, key]) do
    conn.assigns[key]
  end

  defp fetch_value(conn, [:header, key]) do
    conn |> get_req_header(key) |> List.first()
  end

  defp rate_limit_ttl(), do: config()[:ttl] || 60_000
  defp rate_limit_request(), do: config()[:request] || 3
  defp config(), do: Application.get_env(:bugs_channel, :rate_limit)
end
