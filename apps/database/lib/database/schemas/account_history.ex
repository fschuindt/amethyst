defmodule DataBase.Schemas.AccountHistory do
  @moduledoc """
  The bank account daily logbook.

  It's in charge to keep track of all
  `t:DataBase.Schemas.AccountMovement.t/0` `:direction` and `:amount`
  of a `t:DataBase.Schemas.Account.t/0` for each day.

  It acts as logbook. Expresses information over the
  `account_history` database table. Has its `:account_id` and `:date`
  acting both as a composite primary key.

  Provides functions to both register and report informations.
  """

  import Ecto.Query
  import DataBase.Queries.AccountHistory

  use Ecto.Schema

  alias Decimal, as: D
  alias Ecto.Adapters.SQL
  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.{Schemas.Account, Helpers}

  @typedoc """
  A `DataBase.Schemas.AccountHistory` struct.
  """
  @type t :: %__MODULE__{}

  @typedoc """
  A standard Postgrex response to raw SQL queries.

  Represents the registering act response.
  See `register/1`.
  """
  @type query_result_t :: {:ok, Postgrex.Result.t()} | {:error, any()}

  @typedoc """
  Represents the overall shape for the registering input.
  """
  @type registering_data_t :: [pos_integer() | Date.t() | D.t()]

  @typedoc """
  Represents the disposable report filters.
  """
  @type report_range_t :: :total | Date.t() | Date.Range.t()

  @typedoc """
  A standard Ecto response to `DataBase.Schemas.AccountHistory` data
  insertion.
  """
  @type report_result_t :: {:ok, t()} | {:error, any()}

  @primary_key false

  schema "account_history" do
    field :date,               :date, primary_key: true
    field :initial_balance,    :decimal
    field :final_balance,      :decimal
    field :inbounds,           :decimal
    field :outbounds,          :decimal

    belongs_to(:account, Account, primary_key: true)
  end

  @doc """
  Registers a given `t:DataBase.Schemas.AccountMovement.t/0` to its
  respective `t:t/0` logbook properly updating it.

  Creates a new one for the first
  `t:DataBase.Schemas.AccountMovement.t/0` of each day.
  """
  @spec register(Movement.t) :: Movement.t() | :error
  def register(%Movement{} = movement) do
    Repo
    |> SQL.query(update_query(), registering_data(movement))
    |> do_register(movement)
  end

  @doc """
  Given a `t:DataBase.Schemas.Account.t/0` and a `t:report_range_t/0`,
  proceeds into filling a report over the requested period of time.

  Returns a `t:report_result_t/0`. The report data is presented in
  a form of a single `t:t/0`.
  """
  @spec report(Account.t, report_range_t) :: report_result_t()

  def report(%Account{} = account, :total) do
    report(account, Account.activity_range(account))
  end

  def report(%Account{} = account, %Date{} = date) do
    on(account, date)
  end

  def report(%Account{} = account, %Date.Range{} = r) do
    Repo
    |> SQL.query(report_query(), [account.id, r.first, r.last])
    |> do_report()
  end

  @spec do_register(query_result_t, Movement.t) :: Movement.t | :error
  defp do_register({:ok, _r}, %Movement{} = movement), do: movement
  defp do_register(_r, _m), do: :error

  @spec registering_data(Movement.t) :: registering_data_t()
  defp registering_data(%Movement{} = movement) do
    [
      movement.account_id,
      movement.move_on,
      Movement.inbounds_on(movement),
      Movement.outbounds_on(movement),
      Movement.initial_balance_for(movement),
      movement.final_balance
    ]
  end

  @spec build(nil | map) :: t()

  defp build(nil), do: %__MODULE__{}

  defp build(%{} = opts) do
    %__MODULE__{
      inbounds: opts["inbounds"],
      outbounds: opts["outbounds"],
      initial_balance: opts["initial_balance"],
      final_balance: opts["final_balance"]
    }
  end

  @spec on(Account.t, Date.t) :: {:ok, t()}
  defp on(%Account{} = account, %Date{} = date) do
    account.id
    |> on_query(date)
    |> Repo.one()
    |> respond()
  end

  @spec do_report(query_result_t) :: report_result_t()

  defp do_report({:ok, result}) do
    result
    |> Helpers.Postgrex.pack_first()
    |> build()
    |> respond()
  end

  defp do_report(_), do: {:error, :database_failure}

  @spec respond(t | any) :: {:ok, t()}
  defp respond(%__MODULE__{} = history), do: {:ok, history}
  defp respond(_), do: {:ok, build(nil)}

  @spec on_query(pos_integer, Date.t) :: Ecto.Query.t()
  defp on_query(account_id, date) do
    from h in __MODULE__,
      where: h.account_id == ^account_id,
      where: h.date == ^date,
      limit: 1
  end
end
