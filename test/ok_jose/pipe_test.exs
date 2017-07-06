defmodule OkJose.PipeTest do
  use ExUnit.Case
  doctest OkJose.Pipe

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
    use OkJose

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

    def upgrade(%Kitten{}), do: %Tiger{}
    def downgrade(%Tiger{}), do: %Kitten{}

    def kitten, do: %Kitten{}
    def tiger, do: %Tiger{}
  end

  defmodule Dogs do
    def doggie, do: %Doggie{}
  end

  defmodule Home do
    use OkJose

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

  defmodule User do
    use OkJose

    defpipe ok_til_user? do
      x = {:ok, :user} -> {false, x}
      {:ok, n} -> {true, n}
    end

    def inc(3), do: {:ok, :user}
    def inc(x), do: {:ok, x + 1}
  end

  test "til_user? stops piping when got a user" do
    import User

    assert {:ok, 2} =
    {:ok, 0}
    |> inc
    |> inc
    |> ok_til_user?

    assert {:ok, :user} =
    {:ok, 0}
    |> inc
    |> inc
    |> inc
    |> inc
    |> inc
    |> ok_til_user?
  end

  defmodule Maybe do
    use OkJose
    defpipe just do
      {:just, :me} -> "jordan"
      {:just, value} -> value
    end
  end

  test "README Maybe" do
    require Maybe
    assert "Jordan" ==
    {:just, :me}
    |> String.capitalize
    |> String.reverse
    |> Maybe.just
  end


end
