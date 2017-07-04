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
  defp str(a, b), do: "#{b} #{inspect(a)}"

  test "ok/1 returns int value" do
    assert 22 = 22 |> ok
  end

  test "ok/1 returns tuple value" do
    assert {:ok, 22} = {:ok, 22} |> ok
  end

  test "ok/1 invokes function" do
    assert {:ok, 24} = foo() |> ok
  end

  test "ok/1 invokes chain" do
    assert {:ok, 48} = foo() |> dup() |> ok
  end

  test "ok/1 dont chains on error" do
    assert {:error, :div_by_zero} == foo() |> div(0) |> dup() |> ok
  end

  test "ok/1 chains on ok" do
    assert {:ok, 48} = {:ok, 24} |> dup() |> ok
  end

  test "ok/1 mismatch halts chain" do
    assert {:error, 22} = {:ok, 22} |> nop() |> dup() |> ok
  end

  test "ok/1 fn returning mismatch" do
    fun = fn ->
      {:error, 12}
    end
    assert {:error, 12} = fun.() |> dup() |> ok
  end

  test "ok!/1 raises on non-ok" do
    assert_raise CaseClauseError, fn ->
      foo() |> nop() |> dup() |> ok!
    end
  end

  test "ok!/1 returns value" do
    assert 12.0 == foo() |> dup() |> div(4) |> ok!
  end

  test "ok/1 as function" do
    assert "24" ==
      ok(
        {:ok, 12}
        |> dup
        |> Integer.to_string)
  end

  test "ok/2 pipes" do
    assert "24" == {:ok, 12} |> ok(dup) |> ok(inspect)
  end

  test "ok/2 with ok value" do
    assert "yes 24" ==
      {:ok, 12}
      |> ok(dup)
      |> error(dup)
      |> ok(str("yes"))
  end

  test "error/2" do
    assert "no {:ok, 48}" ==
      {:ok, 12} |> dup() |> ok
      |> ok(dup() |> nop)
      |> error(str("no"))
      |> ok(str("yes"))
  end

  test "ok?/2 pipes" do
    assert {:ok, "14"} ==
      {:ok, 12}
      |> fn x -> {:ok, x + 2} end.()
      |> fn x -> {:ok, to_string(x)} end.()
      |> fn x -> {:ok, x + 2} end.()
      |> (pipe_when do
        {:ok, x} when not is_binary(x) -> {true,  x}
        {:ok, y} -> {false, {:ok, y}}
      end)
  end

end
