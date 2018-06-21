defmodule DataBase.Test.Support.Faker do
  @moduledoc """
  A set o functions to provide fake data along testing environments.
  """

  alias Decimal, as: D

  @doc """
  A limited random binary.
  """
  @spec binary() :: binary()
  def binary do
    SecureRandom.base64(16)
  end

  @doc """
  A random `t:Decimal.t/0` smaller than 500 rounded up to 2 decimals.

  Eg.: `112.3`, `44.56`, `318.09`, etc...
  """
  @spec amount(integer) :: D.t()
  def amount(factor \\ 1) do
    500
    |> rand_float()
    |> D.new()
    |> D.round(2)
    |> D.mult(factor)
  end

  @doc """
  A radius/center based `t:Date.Range.t/0` generator.

  Given a positive integer (defaults to `5`) as radius and a
  `t:Date.t/0` (defaults to `today/0`) as center. It returns the 
  respective `t:Date.Range.t/0`.
  """
  @spec date_range(integer, Date.t) :: Date.Range.t()
  def date_range(radius \\ 5, center \\ Date.utc_today) do
    center
    |> Date.add((radius * -1))
    |> Date.range(Date.add(center, radius))
  end

  @spec rand_float(integer) :: float()
  defp rand_float(max) do
    :rand.uniform() + :rand.uniform(max)
  end
end
