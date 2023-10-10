defmodule BugsChannel.Cache do
  @moduledoc """
  This is the application module in charge of handle application cache
  """

  use Nebulex.Cache,
    otp_app: :bugs_channel,
    adapter: Nebulex.Adapters.Partitioned,
    primary_storage_adapter: Nebulex.Adapters.Local

  @doc ~S"""
  Get current cache module

  ## Examples

      iex> BugsChannel.Cache.module()
      BugsChannel.TestCache
  """
  def module() do
    Application.get_env(:bugs_channel, :nebulex_cache)
  end
end
