defmodule BugsChannel.CacheTest do
  use ExUnit.Case

  setup do
    {:ok, _pid} = BugsChannel.Cache.start_link([])

    :ok
  end

  test "puts and retrieve cache" do
    assert BugsChannel.Cache.put(:foo, "bar") == :ok
    assert BugsChannel.Cache.get(:foo) == "bar"
  end
end
