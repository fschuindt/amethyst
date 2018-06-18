defmodule DataBase.Services.Account.Authorize do
  @moduledoc """
  Acts as a service to **authorize** a bank account API token.
  """

  import Ecto.Query

  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Schemas.Account

  @doc """
  Returns a `t:DataBase.Schemas.Account.response_t/0` to represent
  the access authorization for a given `:account_id` and `:api_token`
  set.
  """
  @spec perform(binary, binary) :: Account.response_t()
  def perform(account_id, api_token) do
    account_id
    |> authorization_query(api_token)
    |> Repo.one()
    |> respond()
  end

  @spec respond(Account.t | any) :: Account.response_t()
  defp respond(%Account{} = account), do: {:ok, account}
  defp respond(_any), do: {:error, :unauthorized}

  @spec authorization_query(binary, binary) :: Ecto.Query.t()
  defp authorization_query(id, api_token) do
    from account in Account,
      where: account.id == ^id,
      where: account.api_token == ^api_token,
      limit: 1
  end
end
