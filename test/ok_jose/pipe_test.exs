defmodule OkJose.PipeTest do
  use ExUnit.Case
  doctest OkJose.Pipe

  import OkJose.Pipe

  defmodule Kitten do
    defstruct [:name]
  end

  defmodule Tiger do
    defstruct [:name]
  end

  defmodule Doggie do
    defstruct [:name]
  end

  defmodule Fish do
    defstruct [:name]
  end

  defmodule Cocodrile do
    defstruct [:name]
  end

  defmodule Cats do
    def upgrade(%Kitten{}), do: %Tiger{}
    def downgrade(%Tiger{}), do: %Kitten{}

    use OkJose.Pipe

    defpipe ok_cats do
      k = %Kitten{} -> k
      t = %Tiger{} -> t
    end

    defpipe ok_tiger do
      t = %Tiger{} -> t
    end

    defpipe ok_kitten do
      k = %Kitten{} -> k
    end

    def kitten, do: %Kitten{}
    def tiger, do: %Tiger{}
  end

  defmodule Dogs do
    def doggie, do: %Doggie{}
  end

  defmodule Home do
    use OkJose.Pipe

    defpipe til_danger? do
      t = %{__struct__: x} when x == Tiger or x == Cocodrile -> {false, t}
      x -> {true, x}
    end
  end

  test "defpipe catz pipes with pattern" do
    import Cats
    import Dogs
    assert %Tiger{} = kitten() |> upgrade() |> ok_cats
    assert %Kitten{} = tiger() |> downgrade() |> ok_tiger
    assert %Kitten{} = kitten() |> downgrade() |> ok_tiger
  end

  test "defpipe catz ignores doggie value" do
    import Cats
    import Dogs
    assert %Doggie{} = doggie() |> upgrade() |> ok_cats
    assert %Doggie{} = %Doggie{} |> upgrade() |> ok_cats
  end

  test "defpipe catz/2 with do/end" do
    import Cats
    assert Kitten =
      kitten() |> (ok_cats do %{__struct__: x} -> x end)
    assert Tiger =
      tiger() |> (ok_cats do %{__struct__: x} -> x end)
  end

  test "defpipe safe?" do
    import Home
    assert %Cocodrile{} =
      %Kitten{name: "silvestre"}
      |> fn _ -> %Fish{name: "olivia"} end.()
      |> fn _ -> %Cocodrile{name: "teodoro"} end.()
      |> fn _ -> %Tiger{name: "jorge"} end.()
      |> til_danger?
  end

end
