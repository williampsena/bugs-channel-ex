defmodule BugsChannel.Plugs.HealthCheck do
  @moduledoc """
  This plug is in responsible for checking if the application is in good working condition.
  """

  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Keep calm I'm absolutely alive 🐛")
  end
end
