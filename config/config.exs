use Mix.Config

config :seven, Seven.Entities, entity_app: :sevenotters_tester

# PostgreSQL persistence
#
config :seven,
  persistence: SevenottersPostgres.Storage

# Mongo persistence
#
# config :seven,
#   persistence: SevenottersMongo.Storage
#
# InMemory persistence
#
# config :seven,
#   persistence: Seven.Data.InMemory

# See [docs](https://github.com/ericmj/mongodb/blob/master/lib/mongo.ex)
# for flags documentation
config :seven, Seven.Data.Persistence,
  database: "tester",
  hostname: "127.0.0.1",
  port: 27_017

config :sevenotters_tester, ecto_repos: [SevenottersPostgres.Repo]

config :sevenotters_postgres, SevenottersPostgres.Repo,
  database: "sevenotters_tester_#{Mix.env()}",
  migration_primary_key: [name: :uuid, type: :binary_id],
  migration_timestamps: [type: :utc_datetime],
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10

config :logger, :console,
  format: "$date-$time [$level] $message\n",
  level: :info

config :seven,
  print_commands: false,
  print_events: false

config :logger, level: :error

config :bcrypt_elixir, :log_rounds, 4

import_config "#{Mix.env()}.exs"
