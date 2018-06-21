defmodule DataBase.Schemas.Account do
  @moduledoc """
  The main abstraction to a bank account per say.

  Provides a set of functions to interact with it, since its creation
  to queries about its data. Express information over the `accounts`
  database table.
  """

  import Ecto.Query

  use Ecto.Schema

  alias DataBase.Schemas.AccountTransfer, as: Transfer
  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias Decimal, as: D

  @typedoc """
  A `DataBase.Schemas.Account` struct.
  """
  @type t :: %__MODULE__{}

  @typedoc """
  A standard Ecto response to `DataBase.Schemas.Account` data
  insertion.
  """
  @type response_t :: {:ok, t()} | {:error, any()}

  @typedoc """
  A map containing a `:final_balance` key with a `t:Decimal.t/0`
  value. Or `nil`.

  It's the representation for querying this specific field in the
  database.
  """
  @type final_balance_t :: %{final_balance: D.t()} | nil

  schema "accounts" do
    field :name,        :string
    field :api_token,   :string

    has_many :movements, Movement

    has_many :outgoing_transfers, Transfer,
      foreign_key: :sender_account_id

    has_many :incoming_transfers, Transfer,
      foreign_key: :recipient_account_id

    timestamps()
  end

  @doc """
  Given `t:t/0`, generates a API token to it.
  """
  @spec set_token(t) :: t()
  def set_token(%__MODULE__{} = account) do
    Map.merge(account, %{api_token: generate_api_token()})
  end

  @doc """
  Tries to insert a `t:t/0` struct into database.
  """
  @spec create(t) :: response_t()
  def create(%__MODULE__{} = account), do: Repo.insert(account)

  @doc """
  Checks if a given `t:t/0` has a given `t:Decimal.t/0` as amount
  available in its balance.
  """
  @spec has_funds?(t, D.t) :: boolean()
  def has_funds?(%__MODULE__{} = account, %D{} = amount) do
    Enum.member?([:eq, :gt], D.cmp(balance(account), amount))
  end

  @doc """
  Returns the given `t:t/0` balance.
  """
  @spec balance(t | final_balance_t) :: D.t()

  def balance(%__MODULE__{} = account) do
    account.id
    |> balance_query()
    |> Repo.one()
    |> balance()
  end

  def balance(nil), do: D.new(0)
  def balance(%{} = result), do: result.final_balance

  @doc """
  Registers a outbound `t:DataBase.Schemas.AccountMovement.t/0` for a
  given `t:t/0` and `t:Decimal.t/0` as amount.
  """
  @spec debit(t, D.t) :: Movement.response_t()
  def debit(%__MODULE__{} = account, %D{} = amount) do
    account.id
    |> Movement.build(amount, -1)
    |> Movement.move()
  end

  @doc """
  Registers a inbound `t:DataBase.Schemas.AccountMovement.t/0` for a
  given `t:t/0` and `t:Decimal.t/0` as amount.
  """
  @spec credit(t, D.t) :: Movement.response_t()
  def credit(%__MODULE__{} = account, %D{} = amount) do
    account.id
    |> Movement.build(amount, 1)
    |> Movement.move()
  end

  @doc """
  A sum of all inbound `t:DataBase.Schemas.AccountMovement.t/0`
  `:amount` for a given `t:t/0` on a specific date.
  """
  @spec inbounds_on(pos_integer, Date.t) :: D.t()
  def inbounds_on(id, %Date{} = date) when is_integer(id) do
    id
    |> inbounds_on_query(date)
    |> Repo.one() || D.new(0)
  end

  @doc """
  A sum of all outbound `t:DataBase.Schemas.AccountMovement.t/0`
  `:amount` for a given `t:t/0` on a specific date.
  """
  @spec outbounds_on(pos_integer, Date.t) :: D.t()
  def outbounds_on(id, %Date{} = date) when is_integer(id) do
    id
    |> outbounds_on_query(date)
    |> Repo.one() || D.new(0)
  end

  @doc """
  Given the `:id` of `t:t/0` and a `t:Date.t/0`, it determines the
  `:initial_balance` of the first
  `t:DataBase.Schemas.AccountMovement.t/0` on this date.
  """
  @spec early_balance(pos_integer, Date.t) :: Movement.initial_balance_t
  def early_balance(id, %Date{} = date) when is_integer(id) do
    id
    |> early_balance_query(date)
    |> Repo.one()
  end

  @doc """
  It's a `t:Date.Range.t/0` representing the activity time span of a
  given `t:t/0`.
  """
  @spec activity_range(t) :: nil | Date.Range.t()
  def activity_range(%__MODULE__{} = account) do
    account
    |> opening_date()
    |> range_today()
  end

  @spec generate_api_token() :: binary()
  defp generate_api_token do
    32..64
    |> Enum.random()
    |> SecureRandom.base64()
  end

  @spec range_today(nil | Date.t) :: nil | Date.Range.t()

  defp range_today(nil), do: nil

  defp range_today(%Date{} = date) do
    Date.range(date, Date.utc_today)
  end

  @spec opening_date(t) :: Date.t() | nil
  defp opening_date(%__MODULE__{} = account) do
    account.id
    |> opening_date_query()
    |> Repo.one()
  end

  @spec inbounds_on_query(pos_integer, Date.t) :: Ecto.Query.t()
  defp inbounds_on_query(id, %Date{} = date) when is_integer(id) do
    from m in Movement,
      where: m.account_id == ^id,
      where: m.move_on == ^date,
      where: m.direction == 1,
      select: sum(m.amount)
  end

  @spec outbounds_on_query(pos_integer, Date.t) :: Ecto.Query.t()
  defp outbounds_on_query(id, %Date{} = date) when is_integer(id) do
    from m in Movement,
      where: m.account_id == ^id,
      where: m.move_on == ^date,
      where: m.direction == -1,
      select: sum(m.amount)
  end

  @spec early_balance_query(pos_integer, Date.t) :: Ecto.Query.t()
  defp early_balance_query(id, %Date{} = date) when is_integer(id) do
    from m in Movement,
      where: m.account_id == ^id,
      where: m.move_on == ^date,
      order_by: [asc: m.move_at],
      limit: 1,
      select: [:initial_balance]
  end

  @spec balance_query(pos_integer) :: Ecto.Query.t()
  defp balance_query(id) when is_integer(id) do
    from m in Movement,
      where: m.account_id == ^id,
      order_by: [desc: m.move_at],
      limit: 1,
      select: [:final_balance]
  end

  @spec opening_date_query(pos_integer) :: Ecto.Query.t()
  defp opening_date_query(id) when is_integer(id) do
    from m in Movement,
      where: m.account_id == ^id,
      order_by: [asc: m.move_at],
      select: m.move_on,
      limit: 1
  end
end
