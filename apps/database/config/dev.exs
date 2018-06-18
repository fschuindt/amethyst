use Mix.Config

# Development Environment

config :database, DataBase.Repos.AmethystRepo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("POSTGRES_DB"),
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: System.get_env("POSTGRES_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox
