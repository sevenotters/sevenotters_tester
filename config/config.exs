use Mix.Config

config :seven, Seven.Entities, entity_app: :sevenotters_tester

#
# Mongo persistence
#
# config :seven,
#   persistence: SevenottersMongo.Storage

## See [docs](https://github.com/ericmj/mongodb/blob/master/lib/mongo.ex)
## for flags documentation
# config :seven, Seven.Data.Persistence,
#   database: "cafe",
#   hostname: "127.0.0.1",
#   port: 27_017

#
# Elasticsearch persistence
#
# config :seven,
#   persistence: SevenottersElasticsearch.Storage

# config :seven, Seven.Data.Persistence,
#   url: "http://localhost",
#   port: 9_200

# config :elastix,
#   json_options: [keys: :atoms],
#   httpoison_options: [hackney: [pool: :elastix_pool]]

config :logger, :console,
  format: "$date-$time [$level] $message\n",
  level: :info

config :seven,
  print_commands: false,
  print_events: false

config :logger, level: :error
