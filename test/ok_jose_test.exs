defmodule OkJoseTest do
  use ExUnit.Case
  doctest OkJose

  use OkJose
  import Kernel, except: [div: 2]

  test "returns int value" do
    assert 22 = 22 |> ok
  end

  test "returns tuple value" do
    assert {:ok, 22} = {:ok, 22} |> ok
  end

  test "invokes function" do
    assert {:ok, 24} = foo |> ok
  end

  test "invokes chain" do
    assert {:ok, 48} = foo |> dup |> ok
  end

  test "dont chains on error" do
    assert {:error, :div_by_zero} == foo |> div(0) |> dup |> ok
  end

  test "do chains on ok" do
    assert {:ok, 48} = {:ok, 24} |> dup |> ok
  end

  test "error halts chain" do
    assert {:error, 22} = {:ok, 22} |> nop |> dup |> ok
  end

  test "anon fn returning error" do
    fun = fn ->
      {:error, 12}
    end
    assert {:error, 12} = fun.() |> dup |> ok
  end

  test "ok! raises on non-ok" do
    assert_raise CaseClauseError, fn ->
      foo |> nop |> ok!
    end
  end

  test "ok! returns value" do
    assert 12.0 == foo |> dup |> div(4) |> ok!
  end

  defp foo, do: {:ok, 24}
  defp dup(x), do: {:ok, x * 2}
  defp nop(x), do: {:error, x}
  defp div(_x, 0), do: {:error, :div_by_zero}
  defp div(x, y), do: {:ok, x / y}

end
