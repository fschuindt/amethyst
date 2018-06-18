defmodule Teller.GraphQL.Resolvers.AccountHistory.Overall do
  @moduledoc """
  Absinthe resolver to the `DataBase.Schemas.AccountHistory.report/2`
  with `:total` argument.

  GraphQL endpoint to allow authorized users to obtain account
  logbook reports for the whole history.
  """

  alias Absinthe.Resolution, as: Res
  alias Teller.ErrorMessages, as: Error
  alias DataBase.Schemas.AccountHistory, as: History
  alias DataBase.Schemas.Account

  @doc """
  Act as a Absinthe resolver to report account logbooks since the
  creation of the account.

  The client must provide authorization headers.
  """
  @spec resolve(Res.arguments, Res.t) :: History.report_result_t()
  def resolve(args, info) do
    do_resolve(info.context[:account], args, info)
  end

  @spec do_resolve(any, Res.arguments, Res.t) :: History.report_result_t()

  defp do_resolve(%Account{} = account, _args, _info) do
    History.report(account, :total)
  end

  defp do_resolve(_account, _args, _info), do: Error.unauthorized
end
