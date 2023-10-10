defmodule BugsChannel.TestCache do
  @moduledoc """
  This is the module in charge of the Nebulex cache in test mode.
  """

  use Nebulex.Cache,
    otp_app: :bugs_channel,
    adapter: Nebulex.Adapters.Nil
end
