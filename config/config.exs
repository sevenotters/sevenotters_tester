use Mix.Config

config :seven, Seven.Entities, entity_app: :sevenotters_tester

#
# Mongo persistence
#
# config :seven,
#   persistence: SevenottersMongo.Storage
config :seven,
  persistence: Seven.Data.InMemory

# See [docs](https://github.com/ericmj/mongodb/blob/master/lib/mongo.ex)
# for flags documentation
config :seven, Seven.Data.Persistence,
  database: "tester",
  hostname: "127.0.0.1",
  port: 27_017

config :logger, :console,
  format: "$date-$time [$level] $message\n",
  level: :info

config :seven,
  print_commands: false,
  print_events: false

config :logger, level: :error

config :bcrypt_elixir, :log_rounds, 4
