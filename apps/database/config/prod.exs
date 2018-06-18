use Mix.Config

# Production Environment

config :database, DataBase.Repos.AmethystRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "${POSTGRES_DB}",
  username: "${POSTGRES_USER}",
  password: "${POSTGRES_PASSWORD}",
  hostname: "${POSTGRES_HOST}"
