alias BugsChannel.Applications

{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _pid} = BugsChannel.TestCache.start_link([])

{:ok, _} = Supervisor.start_link(Applications.Mongo.start("mongo"),
  strategy: :one_for_one,
  name: BugsChannel.Supervisor
)

ExUnit.start()
