defmodule BugsChannel.Plugs.ErrorFallback do
  @moduledoc """
  This module includes API error fallback
  """

  import BugsChannel.Plugs.Api
  import BugsChannel.Api.Views.Error

  def fallback(%Plug.Conn{} = conn, _), do: conn

  def fallback(response, conn) do
    case response do
      {:error, %Ecto.Changeset{valid?: false} = changeset} ->
        send_unprocessable_entity_resp(conn, render_ecto_error(changeset))

      {:error, :validation_error, error} ->
        send_unprocessable_entity_resp(conn, render_error(error))

      {:error, :not_found_error, _error} ->
        send_not_found_resp(conn)

      {:error, error} ->
        send_unknown_error_resp(conn, render_error(error))

      _ ->
        send_unknown_error_resp(conn, "Internal Server Error")
    end
  end
end
