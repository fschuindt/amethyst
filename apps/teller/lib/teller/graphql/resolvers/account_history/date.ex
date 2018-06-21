defmodule Teller.GraphQL.Resolvers.AccountHistory.Date do
  @moduledoc """
  Absinthe resolver to the `DataBase.Schemas.AccountHistory.report/2`
  with single date arguments.

  GraphQL endpoint to allow authorized users to obtain account
  logbook reports for a specific date.
  """

  alias Absinthe.Resolution, as: Res
  alias Teller.ErrorMessages, as: Error
  alias DataBase.Schemas.AccountHistory, as: History
  alias DataBase.Schemas.Account

  @doc """
  Act as a Absinthe resolver to report account logbooks over a single
  `t:Date.t/0` argument.

  The client must provide authorization headers.
  """
  @spec resolve(Res.arguments, Res.t) :: History.report_result_t()
  def resolve(args, info) do
    do_resolve(info.context[:account], args, info)
  end

  @spec do_resolve(any, Res.arguments, Res.t) :: History.report_result_t()

  defp do_resolve(%Account{} = account, args, _info) do
    report(account, args[:date])
  end

  defp do_resolve(_account, _args, _info), do: Error.unauthorized

  @spec report(any, any) :: History.report_result_t()

  defp report(account, nil) do
    History.report(account, Date.utc_today)
  end

  defp report(account, %Date{} = date) do
    History.report(account, date)
  end

  defp report(_account, _period) do
    Error.invalid_input
  end
end
