defmodule Teller.GraphQL.Resolvers.AccountHistory.Period do
  @moduledoc """
  Absinthe resolver to the `DataBase.Schemas.AccountHistory.report/2`
  with date range arguments.

  GraphQL endpoint to allow authorized users to obtain account
  logbook reports for a specific date range.
  """

  alias Absinthe.Resolution, as: Res
  alias Teller.ErrorMessages, as: Error
  alias DataBase.Schemas.AccountHistory, as: History
  alias DataBase.Schemas.Account

  @doc """
  Act as a Absinthe resolver to report account logbooks over a date
  range argument.

  The client must provide authorization headers.
  """
  @spec resolve(Res.arguments, Res.t) :: History.report_result_t()
  def resolve(args, info) do
    do_resolve(info.context[:account], args, info)
  end

  @spec do_resolve(any, Res.arguments, Res.t) :: History.report_result_t()

  defp do_resolve(%Account{} = account, args, _info) do
    report(account, args[:from], args[:to])
  end

  defp do_resolve(_account, _args, _info), do: Error.unauthorized

  @spec report(any, any, any) :: History.report_result_t()

  defp report(account, %Date{} = from, %Date{} = to) do
    with true     <- (from < to),
         period   <- Date.range(from, to) do
      History.report(account, period)
    else
      _e ->
        Error.invalid_input
    end
  end

  defp report(_account, _from, _to), do: Error.invalid_input
end
