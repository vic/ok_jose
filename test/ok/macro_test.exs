defmodule Ok.MacroTest do
  use ExUnit.Case
  doctest Ok.Macro

  import Ok.Macro

  defmacrop assert_piped(code, piped) do
    piped = Macro.escape(piped)
    code = Macro.escape(code)
    quote bind_quoted: [piped: piped, code: code] do
      assert Macro.unpipe(piped) == Macro.unpipe(piped(code))
    end
  end

  test "piped int literal" do
    assert_piped 1, 1
  end

  test "piped no-arg call" do
    assert_piped(foo(), foo())
  end

  test "piped one arg literal call" do
    assert_piped(foo(1), 1 |> foo())
  end

  test "piped two arg literal call" do
    assert_piped(foo(1, 2), 1 |> foo(2))
  end

  test "piped nested call" do
    assert_piped(foo(bar(1)), 1 |> bar() |> foo())
  end

end
