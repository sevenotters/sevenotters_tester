import Config

config :sevenotters_postgres, SevenottersPostgres.Repo,
  pool: Ecto.Adapters.SQL.Sandbox
