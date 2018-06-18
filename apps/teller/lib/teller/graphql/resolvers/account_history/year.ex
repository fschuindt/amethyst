defmodule Teller.GraphQL.Resolvers.AccountHistory.Year do
  @moduledoc """
  Absinthe resolver to the `DataBase.Schemas.AccountHistory.report/2`
  with a year period argument..

  GraphQL endpoint to allow authorized users to obtain account
  logbook reports for a specific year.
  """

  alias Absinthe.Resolution, as: Res
  alias Teller.ErrorMessages, as: Error
  alias DataBase.Schemas.AccountHistory, as: History
  alias DataBase.Schemas.Account

  @doc """
  Act as a Absinthe resolver to report account logbooks over a year.

  The client must provide authorization headers.
  """
  @spec resolve(Res.arguments, Res.t) :: History.report_result_t()
  def resolve(args, info) do
    do_resolve(info.context[:account], args, info)
  end

  @spec do_resolve(any, Res.arguments, Res.t) :: History.report_result_t()

  defp do_resolve(%Account{} = account, args, _info) do
    with {:ok, from}    <- Date.new(args[:year], 1, 1),
         {:ok, to}      <- Date.new(args[:year], 12, 31),
         period         <- Date.range(from, to) do
      History.report(account, period)
    else
      _e ->
        Error.invalid_input
    end
  end

  defp do_resolve(_account, _args, _info), do: Error.unauthorized
end
