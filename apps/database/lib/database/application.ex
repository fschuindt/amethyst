defmodule DataBase.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(DataBase.Repos.AmethystRepo, [])
    ]

    opts = [strategy: :one_for_one, name: DataBase.Supervisor]

    :ok = :error_logger.add_report_handler(Sentry.Logger)

    Supervisor.start_link(children, opts)
  end
end
