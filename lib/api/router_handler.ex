defmodule BugsChannel.Api.RouterHandler do
  @moduledoc """
  This plug is in responsible for handle matched routes
  """

  defmacro __using__(_opts) do
    quote location: :keep do
      def controller(%Plug.Conn{} = conn, controller_module, action, params \\ %{})
          when is_atom(action) do
        params = Map.merge(conn.params, params)

        apply(controller_module, action, [conn, params])
      end
    end
  end
end
