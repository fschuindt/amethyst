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
    Supervisor.start_link(children, opts)
  end
end
