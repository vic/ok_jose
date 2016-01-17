defmodule OkJose.PipeTest do
  use ExUnit.Case
  doctest OkJose.Pipe

  import OkJose.Pipe

  defmodule Kitten do
    defstruct []
  end

  defmodule Tiger do
    defstruct []
  end

  defmodule Doggie do
    defstruct []
  end

  defmodule Catz do
    def upgrade(%Kitten{}), do: %Tiger{}
    def downgrade(%Tiger{}), do: %Kitten{}

    use OkJose.Pipe
    defpipe catz do
      k = %Kitten{} -> k
      t = %Tiger{} -> t
    end

    def kitten, do: %Kitten{}
    def tiger, do: %Tiger{}
  end

  defmodule Dogs do
    def doggie, do: %Doggie{}
  end


  test "defpipe catz pipes with pattern" do
    import Catz
    import Dogs
    assert %Tiger{} = kitten |> upgrade |> catz
  end

  test "defpipe catz ignores doggie value" do
    import Catz
    import Dogs
    assert %Doggie{} = doggie |> upgrade |> catz
  end

end
