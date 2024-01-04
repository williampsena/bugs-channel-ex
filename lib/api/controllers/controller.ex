defmodule BugsChannel.Api.Controllers.Controller do
  @moduledoc """
  This base controller  responsible for provide core features
  """

  defmacro __using__(_opts) do
    quote location: :keep do
      import Plug.Conn
      import BugsChannel.Plugs.Api
      import BugsChannel.Api.Views.PagedResults
    end
  end
end
