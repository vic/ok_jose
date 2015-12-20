defmodule OkTest do
  use ExUnit.Case
  doctest Ok

  import Ok

  # @tag :skip
  # test "returns int value" do
  #   assert 22 = 22 |> ok
  # end

  # @tag :skip
  # test "returns tuple value" do
  #   assert {1, 2} = {1, 2} |> ok
  # end

  # @tag :skip
  # test "invokes function" do
  #   assert 24 = foo |> ok
  # end

  # @tag :skip
  # test "invokes chain" do
  #   assert 48 = foo |> dup |> ok
  # end

  test "dont chains on error" do
    assert {:error, 24} == foo |> nop |> dup |> ok
  end

  # @tag :skip
  # test "do chains on ok" do
  #   assert {:ok, 48} = foo |> yup |> dup |> ok
  # end

  defp foo, do: {:ok, 24}
  defp dup(x), do: x * 2
  #defp yup(x), do: {:ok, x}
  defp nop(x), do: {:error, x}

end
