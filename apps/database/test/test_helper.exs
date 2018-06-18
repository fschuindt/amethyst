ExUnit.start()

DataBase.Repos.AmethystRepo
|>Ecto.Adapters.SQL.Sandbox.mode(:manual)

Code.load_file("test/support/faker.exs")
Code.load_file("test/support/factories/accounts.exs")
Code.load_file("test/support/factories/account_movements.exs")
