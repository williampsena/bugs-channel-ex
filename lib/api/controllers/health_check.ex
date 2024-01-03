defmodule BugsChannel.Api.Controllers.HealthCheck do
  @moduledoc """
  This controller is in responsible for checking if the application is in good working condition.
  """

  use BugsChannel.Api.Controllers.Controller

  def index(%Plug.Conn{} = conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Keep calm I'm absolutely alive 🐛")
  end
end
