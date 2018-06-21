defmodule Teller.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: Teller.Router,
        options: [
          ip: {0, 0, 0, 0},
          port: 7171
        ]
      )
    ]

    opts = [strategy: :one_for_one, name: Teller.Supervisor]

    :ok = :error_logger.add_report_handler(Sentry.Logger)

    Supervisor.start_link(children, opts)
  end
end
