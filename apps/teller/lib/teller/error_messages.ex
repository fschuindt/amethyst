defmodule Teller.ErrorMessages do
  @moduledoc """
  A collection of all API level error messages.
  """

  @typedoc """
  Usual error tuple with message.
  """
  @type t :: {:error, binary()}

  @doc """
  When the client provides API credentials for creating a account.
  """
  @spec already_logged() :: t()
  def already_logged do
    {:error, "Already logged in."}
  end

  @doc """
  Wrong or not provided API credentials.
  """
  @spec unauthorized() :: t()
  def unauthorized do
    {:error, "Unauthorized."}
  end

  @doc """
  API level error for missing required arguments.
  """
  @spec required_input() :: t()
  def required_input do
    {:error, "Supressed required input."}
  end

  @doc """
  API level error for invalid arguments.
  """
  @spec invalid_input() :: t()
  def invalid_input do
    {:error, "Invalid provided input."}
  end

  @doc """
  Inexistent recipient account or wrong `recipientAccountId`.
  """
  @spec invalid_recipient() :: t()
  def invalid_recipient do
    {:error, "Invalid recipient account."}
  end

  @doc """
  The `amount` is either invalid or greater than sender's balance.

  Zero or negative amounts are considered invalid.
  """
  @spec insufficient_funds() :: t()
  def insufficient_funds do
    {:error, "Insufficient funds or invalid amount."}
  end

  @doc """
  Unexpected internal error.
  """
  @spec operation_failed() :: t()
  def operation_failed do
    {:error, "Operation failed."}
  end
end
