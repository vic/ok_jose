defmodule OkJoseTest do
  use ExUnit.Case
  doctest OkJose

  import OkJose

  test "returns int value" do
    assert 22 = 22 |> ok
  end

  test "returns tuple value" do
    assert {1, 2} = {1, 2} |> ok
  end

  test "invokes function" do
    assert {:ok, 24} = foo |> ok
  end

  test "invokes chain" do
    assert 48 = foo |> dup |> ok
  end

  test "ok tuple is left unmodified by ok" do
    assert {:ok, 22} == {:ok, 22} |> ok
  end

  test "dont chains on error" do
    assert {:error, 24} == foo |> nop |> dup |> ok
  end

  test "do chains on ok" do
    assert 48 = {:ok, 24} |> yup |> dup |> ok
  end

  defp foo, do: {:ok, 24}
  defp dup(x), do: x * 2
  defp yup(x), do: {:ok, x}
  defp nop(x), do: {:error, x}

end
