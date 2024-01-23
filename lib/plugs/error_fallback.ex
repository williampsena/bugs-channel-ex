defmodule BugsChannel.Plugs.ErrorFallback do
  @moduledoc """
  This module includes API error fallbacks
  """

  import BugsChannel.Plugs.Api
  import BugsChannel.Api.Views.Error

  def fallback(%Plug.Conn{} = conn, _), do: conn

  def fallback(response, conn) do
    case response do
      {:error, error} -> send_unknown_error_resp(conn, render_error(error))
      _ -> send_unknown_error_resp(conn, "Internal Server Error")
    end
  end
end
