defmodule OkJoseTest do
  use ExUnit.Case
  doctest OkJose

  use OkJose
  import Kernel, except: [div: 2]

  defp foo, do: {:ok, 24}
  defp dup(x), do: {:ok, x * 2}
  defp nop(x), do: {:error, x}
  defp div(_x, 0), do: {:error, :div_by_zero}
  defp div(x, y), do: {:ok, x / y}

  test "ok/1 returns int value" do
    assert 22 = 22 |> ok
  end

  test "ok/1 returns tuple value" do
    assert {:ok, 22} = {:ok, 22} |> ok
  end

  test "ok/1 invokes function" do
    assert {:ok, 24} = foo |> ok
  end

  test "ok/1 invokes chain" do
    assert {:ok, 48} = foo |> dup |> ok
  end

  test "ok/1 dont chains on error" do
    assert {:error, :div_by_zero} == foo |> div(0) |> dup |> ok
  end

  test "ok/1 chains on ok" do
    assert {:ok, 48} = {:ok, 24} |> dup |> ok
  end

  test "ok/1 mismatch halts chain" do
    assert {:error, 22} = {:ok, 22} |> nop |> dup |> ok
  end

  test "ok/1 fn returning mismatch" do
    fun = fn ->
      {:error, 12}
    end
    assert {:error, 12} = fun.() |> dup |> ok
  end

  test "ok!/1 raises on non-ok" do
    assert_raise CaseClauseError, fn ->
      foo |> nop |> dup |> ok!
    end
  end

  test "ok!/1 returns value" do
    assert 12.0 == foo |> dup |> div(4) |> ok!
  end

  test "ok/1 as function" do
    assert "24" ==
      ok(
        {:ok, 12}
        |> dup
        |> Integer.to_string)
  end

end
