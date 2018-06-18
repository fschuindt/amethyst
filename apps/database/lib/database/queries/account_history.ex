defmodule DataBase.Queries.AccountHistory do
  @moduledoc false

  @doc """
  The `t:DataBase.Schemas.AccountHistory.t/0` SQL query to a date
  range based report.
  """
  @spec report_query() :: binary()
  def report_query do
    """
      select
        sum(inbounds) as inbounds,
        sum(outbounds) as outbounds,
        max(initial_balance) as initial_balance,
        max(final_balance) as final_balance

        from (
          select
          account_id, inbounds, outbounds,

          first_value(initial_balance) over (
            partition by account_id
            order by date
          ) as initial_balance,

          last_value(final_balance) over (
            partition by account_id

            order by
            date rows between unbounded
            preceding and unbounded following

          ) as final_balance

          from account_history
            where account_id = $1
            and "date" between $2 and $3

        ) as report group by report.account_id
    """
  end

  @doc """
  The `t:DataBase.Schemas.AccountHistory.t/0` SQL query to register
  or update the logbook.

  Note the `on conflict (account_id, date) do update`.
  """
  @spec update_query() :: binary()
  def update_query do
    """
      insert into account_history(
        account_id, date, inbounds, outbounds,
        initial_balance, final_balance
      )

      values ($1, $2, $3, $4, $5, $6)

      on conflict (account_id, date) do update

      set
        inbounds = excluded.inbounds,
        outbounds = excluded.outbounds,
        final_balance = excluded.final_balance
    """
  end
end
