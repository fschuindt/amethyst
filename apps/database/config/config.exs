use Mix.Config

import_config "#{Mix.env}.exs"

config :database, ecto_repos: [DataBase.Repos.AmethystRepo]
