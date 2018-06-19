defmodule Amethyst.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Amethyst",
      source_url: "https://github.com/USER/PROJECT",
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: [:dev, :test], runtime: false},
      {:distillery, "~> 1.5", runtime: false},
      {:excoveralls, "~> 0.8", only: [:dev, :test]},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v0.1.0",
      logo: "logo.png",
      source_url: "https://github.com/fschuindt/amethyst",
      extras: [
        "README.md",
        "apps/database/Database.md",
        "apps/teller/Teller.md",
        "apps/teller/API.md"
      ],
      groups_for_modules: [
        "Ecto Schemas": [
          DataBase.Schemas.Account,
          DataBase.Schemas.AccountMovement,
          DataBase.Schemas.AccountTransfer,
          DataBase.Schemas.AccountHistory
        ],

        "Database Services": [
          DataBase.Services.Account.Authorize,
          DataBase.Services.Account.Open,
          DataBase.Services.Account.Transfer,
          DataBase.Services.Account.Withdraw
        ],

        "HTTP Plug": [
          Teller.Router,
          Teller.Authorize,
          Teller.ErrorMessages
        ],

        "GraphQL Resolvers": [
          Teller.GraphQL.Resolvers.Account.Open,
          Teller.GraphQL.Resolvers.Account.Transfer,
          Teller.GraphQL.Resolvers.Account.Withdraw,
          Teller.GraphQL.Resolvers.AccountHistory.Date,
          Teller.GraphQL.Resolvers.AccountHistory.Month,
          Teller.GraphQL.Resolvers.AccountHistory.Overall,
          Teller.GraphQL.Resolvers.AccountHistory.Period,
          Teller.GraphQL.Resolvers.AccountHistory.Year
        ]
      ]
    ]
  end
end
