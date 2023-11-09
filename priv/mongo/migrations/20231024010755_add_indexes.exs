defmodule Mongo.Migrations.Mongo.AddIndexes do
  def up() do
    build_events_indexes()
    build_events_meta_indexes()
    build_service_indexes()
  end

  def down() do
    Mongo.drop_index(:mongo, "events", "service_meta_env_index")
    Mongo.drop_index(:mongo, "events", "release_index")
  end

  defp build_events_indexes() do
    indexes = [
      [key: [service_id: 1, meta_id: 1, environment: 1], name: "service_meta_env_index", unique: false],
      [key: [release: 1], name: "release_index", unique: false],
      [key: [inserted_at: 1], name: "expires_index", expireAfterSeconds: days_expiration()],
    ]

    Mongo.create_indexes(:mongo, "events", indexes)
  end

  defp build_events_meta_indexes() do
    indexes = [
      [key: [key: 1, environment: 1], name: "key_environment_index", unique: true],
      [key: [updated_at: 1], name: "expires_index", expireAfterSeconds: days_expiration()],
    ]

    Mongo.create_indexes(:mongo, "events", indexes)
  end

  defp build_service_indexes() do
    indexes = [
      [key: [teams: 1], name: "teams_index", unique: true],
    ]

    Mongo.create_indexes(:mongo, "services", indexes)
  end

  defp days_expiration do
    days  =  System.get_env("EVENTS_DAYS_EXPIRES", "7")
    String.to_integer(days) * 3600 * 24
  end
end
