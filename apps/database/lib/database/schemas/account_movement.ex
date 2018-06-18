defmodule DataBase.Schemas.AccountMovement do
  @moduledoc """
  The bank account funds movimentation.

  Every time a `t:DataBase.Schemas.Account.t/0` adds or removes
  funds, it's in other words: Inserting a new `t:t/0`. Which are
  simply called **Movements**. They can add *(inbound)* or remove
  *(outbound)* funds.

  A **Movement** inbound/outbound is determined by its `:direction`
  (which is `1` for inbounds or `-1` for outbounds). So its *real
  amount* is represented by `direction * amount`, as its `:amount` is
  always positive regardless of direction.

  The act of registering a new movement to a
  `t:DataBase.Schemas.Account.t/0` is called to **move** a movement.

  This moving operation ensures to set required internal values and
  to write/update its respective
  `t:DataBase.Schemas.AccountHistory.t/0` logbook.

  See `move/1`.

  Expresses information over the `account_movements` database table.
  """

  import Map, only: [merge: 2]
  import Ecto.Query, only: [last: 2, where: 2]

  use Ecto.Schema

  alias Decimal, as: D
  alias Ecto.Association.NotLoaded
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Schemas.AccountHistory, as: History
  alias DataBase.Schemas.Account

  @typedoc """
  A `DataBase.Schemas.AccountMovement` struct.
  """
  @type t :: %__MODULE__{}

  @typedoc """
  A standard Ecto response to `DataBase.Schemas.AccountMovement` data
  insertion.
  """
  @type response_t :: {:ok, t()} | {:error, any()}

  @typedoc """
  A map containing a `:initial_balance` key with a `t:Decimal.t/0`
  value. Or `nil`.

  It's the representation for querying this specific field in the
  database.
  """
  @type initial_balance_t :: %{initial_balance: D.t()} | nil

  @typedoc """
  A group of fields to be set after building a `t:t/0`. Prior its
  insertion.
  """
  @type missing_values_t :: %{
    move_on: Date.t(),
    move_at: DateTime.t(),
    initial_balance: D.t(),
    final_balance: D.t()
  }

  @typedoc """
  A group of fields that represents the association of a `t:t/0` to
  the `t:DataBase.Schemas.Account.t/0` last
  `t:DataBase.Schemas.AccountMovement.t/0`. A.k.a. *previous
  movement*.
  """
  @type precedent_assoc_t :: nil | %{
    previous_movement_id: pos_integer(),
    previous_movement: t()
  }

  schema "account_movements" do
    field :direction,              :integer
    field :amount,                 :decimal
    field :initial_balance,        :decimal
    field :final_balance,          :decimal
    field :move_at,                :utc_datetime
    field :move_on,                :date

    belongs_to(:account, Account)
    belongs_to(:previous_movement, __MODULE__)

    timestamps()
  end

  @doc """
  Builds a `t:t/0` over the given arguments.
  """
  @spec build(pos_integer, D.t, integer) :: t()
  def build(account_id, %D{} = amount, direction) do
    %__MODULE__{
      account_id: account_id,
      amount: amount,
      direction: direction
    }
  end

  @doc """
  The only allowed way to register a `t:t/0`.

  It will set its *previous movement* (if any), then compute its
  required internal values and register with the respective
  `t:DataBase.Schemas.AccountHistory.t/0` logbook.

  Only after registering to the logbook the `t:t/0` is inserted.
  """
  @spec move(t) :: response_t()
  def move(%__MODULE__{} = movement) do
    movement
    |> set_previous_movement()
    |> set_missing_values()
    |> History.register()
    |> Repo.insert()
  end

  @doc """
  Determines if a given `t:Decimal.t/0` is greater than zero.
  """
  @spec valid_amount?(D.t) :: boolean()
  def valid_amount?(%D{} = amount) do
    D.cmp(amount, 0) == :gt
  end

  @doc """
  It's a `t:Decimal.t/0` to represent the addition of
  `t:DataBase.Schemas.AccountHistory.t/0` (logbook) `:inbounds_on`
  with the given `t:t/0` *movement inbound value*.

  The *movement inbound value* is the `t:t/0` `:amount` if it's a
  inbound movement. Otherwise it's zero.
  """
  @spec inbounds_on(t) :: D.t()
  def inbounds_on(%__MODULE__{} = m) do
    with inbounds <- Account.inbounds_on(m.account_id, m.move_on),
         inbound  <- inbound_amount(m, m.direction),
         do: D.add(inbounds, inbound)
  end

  @doc """
  It's a `t:Decimal.t/0` to represent the addition of
  `t:DataBase.Schemas.AccountHistory.t/0` (logbook) `:outbounds_on`
  with the given `t:t/0` *movement outbound value*.

  The *movement outbound value* is the `t:t/0` `:amount` if it's a
  outbound movement. Otherwise it's zero.
  """
  @spec outbounds_on(t) :: D.t()
  def outbounds_on(%__MODULE__{} = m) do
    with outbounds <- Account.outbounds_on(m.account_id, m.move_on),
         outbound  <- outbound_amount(m, m.direction),
         do: D.add(outbounds, outbound)
  end

  @doc """
  When a given `t:t/0` is the first of its day, it returns the
  `t:t/0` `:initial_balance`. Otherwise it returns the
  `DataBase.Schemas.Account.early_balance/2` `:initial_balance` for
  the given `t:t/0`.
  """
  @spec initial_balance_for(t) :: D.t()
  def initial_balance_for(%__MODULE__{} = movement) do
    movement.account_id
    |> Account.early_balance(movement.move_on)
    |> do_initial_balance_for(movement)
  end

  @spec do_initial_balance_for(initial_balance_t, t) :: D.t()

  defp do_initial_balance_for(nil, %__MODULE__{} = movement) do
    movement.initial_balance
  end

  defp do_initial_balance_for(%{} = result, _movement) do
    result.initial_balance
  end

  @spec set_previous_movement(t) :: t()
  defp set_previous_movement(%__MODULE__{} = movement) do
    merge(movement, get_precedent_assoc(movement.account_id))
  end

  @spec set_missing_values(t) :: t()
  defp set_missing_values(%__MODULE__{} = movement) do
    merge(movement, missing_values(movement))
  end

  @spec get_precedent_assoc(pos_integer) :: %{} | t()
  defp get_precedent_assoc(account_id) when is_integer(account_id) do
    __MODULE__
    |> last(:move_at)
    |> where(account_id: ^account_id)
    |> Repo.one()
    |> precedent_assoc()
  end

  @spec missing_values(t, DateTime.t) :: missing_values_t()
  defp missing_values(%__MODULE__{} = m, at \\ DateTime.utc_now) do
    %{
      move_on: DateTime.to_date(at),
      move_at: at,
      initial_balance: final_balance(m.previous_movement),
      final_balance: operate(m.previous_movement, m)
    }
  end

  @spec precedent_assoc(nil | t) :: precedent_assoc_t()

  defp precedent_assoc(nil), do: %{}

  defp precedent_assoc(%__MODULE__{} = movement) do
    %{
      previous_movement_id: movement.id,
      previous_movement: movement
    }
  end

  @spec final_balance(%NotLoaded{} | t) :: D.t()

  defp final_balance(%NotLoaded{}), do: D.new(0)

  defp final_balance(%__MODULE__{} = movement) do
    movement.final_balance
  end

  @spec operate(%NotLoaded{} | t, t) :: D.t()
  defp operate(precedent, %__MODULE__{} = movement) do
    D.add(final_balance(precedent), signed_amount(movement))
  end

  @spec signed_amount(t) :: D.t()
  defp signed_amount(%__MODULE__{} = movement) do
    D.mult(movement.amount, movement.direction)
  end

  @spec inbound_amount(t, integer) :: D.t()

  defp inbound_amount(_movement, -1), do: D.new(0)

  defp inbound_amount(%__MODULE__{} = movement, 1) do
    movement.amount
  end

  @spec outbound_amount(t, integer) :: D.t()

  defp outbound_amount(_movement, 1), do: D.new(0)

  defp outbound_amount(%__MODULE__{} = movement, -1) do
    movement.amount
  end
end
