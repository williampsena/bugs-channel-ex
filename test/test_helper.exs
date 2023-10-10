{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _pid} = BugsChannel.TestCache.start_link([])

ExUnit.start()
