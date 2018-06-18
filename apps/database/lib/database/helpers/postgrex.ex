defmodule DataBase.Helpers.Postgrex do
  @moduledoc false

  @doc """
  For a non-empty `t:Postgrex.Result.t/0`, it returns the first
  result row packed into a map.

  If the result is empty, it returns `nil`.
  """
  @spec pack_first(Postgrex.Result.t) :: map() | nil
  def pack_first(%Postgrex.Result{} = result) do
    do_pack_first(result.columns, result.rows)
  end

  @spec do_pack_first(list, list) :: map() | nil
  defp do_pack_first(cols, [first | _n]) do
    cols
    |> Enum.zip(first)
    |> Enum.into(%{})
  end

  defp do_pack_first(_cols, _rows), do: nil
end
