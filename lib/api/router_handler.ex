defmodule BugsChannel.Api.RouterHandler do
  @moduledoc """
  This plug is in responsible for handle matched routes
  """

  defmacro __using__(_opts) do
    quote location: :keep do
      import BugsChannel.Plugs.ErrorFallback

      def controller(%Plug.Conn{} = conn, controller_module, action, params \\ %{})
          when is_atom(action) do
        params = Map.merge(conn.params, params)

        controller_module
        |> apply(action, [conn, params])
        |> fallback(conn)
      end
    end
  end
end
