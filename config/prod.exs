use Mix.Config

config :sentry,
  dsn: "${SENTRY_DSN}",
  environment_name: :prod,
  enable_source_code_context: false,
  root_source_code_path: File.cwd!,
  tags: %{
    env: "production"
  },
  included_environments: [:prod]
