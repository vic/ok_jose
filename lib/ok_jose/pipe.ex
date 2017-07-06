defmodule OkJose.Pipe do

  @moduledoc """
  Functions for piping tagged tuples
  """

  require OkJose.DefPipe
  import OkJose.DefPipe, only: [def_pipe: 2]

  @doc """
  Lets you define a named pipe

  The `ok/2` pipe is defined like:

      defpipe ok do
        {:ok, value} -> value
      end

  But you are not limited to :ok atoms

      defmodule Maybe do
        use OkJose

        defpipe just do
          {:just, :me} -> "jordan"
          {:just, value} -> value
          {:ok, value} -> value
        end
      end

  Once defined, you can use pipe to your
  new named macro. When a non-matching value
  is found, the pipe execution is stoped.

      assert "Jordan" ==
        {:just, :me}
        |> String.capitalize
        |> String.reverse
        |> Maybe.just

  If the pipe name ends with a bang like `ok!` an
  error is raised on mismatch

      defpipe ok! do
        {:ok, value} -> value
      end

  """
  defmacro defpipe(name, clauses) do
    quote do
      OkJose.DefPipe.def_pipe(unquote(name), unquote(clauses))
    end
  end

  @doc """
  Pipes values down while they match `{:ok, value}`

      iex> use OkJose
      ...> {:ok, 10}
      ...> |> fn x -> x * 20 end.()
      ...> |> Pipe.ok
      200

      iex> use OkJose
      ...> {:ok, 10}
      ...> |> fn x -> {:error, x + 10} end.()
      ...> |> fn x -> {:ok, x + 2} end.()
      ...> |> Pipe.ok
      {:error, 20}

  """
  def_pipe ok do
    {:ok, value} -> value
  end

  @doc """
  Same as `ok/2` but raises on value mismatch
  """
  def_pipe ok! do
    {:ok, value} -> value
  end

  @doc """
  Pipes values down while they match `{:error, value}`
  """
  def_pipe error do
    {:error, value} -> value
  end

  @doc """
  Sames as `error/2` but raises on value mismatch
  """
  def_pipe error! do
    {:error, value} -> value
  end


  @doc """
  Tags a value with an atom inside a pipe

      iex> use OkJose
      ...> 20
      ...> |> Pipe.tag(:ok)
      {:ok, 20}

  """
  def tag(value, tag) do
    {tag, value}
  end

  @doc """
  Tags the value returned by a pipe fragment.

  This macro is useful for working with functions
  that are not tagged-tuple aware, that is, they
  return just plain values, like `Map.put/3` which
  returns a Map data structure.

      iex> use OkJose
      ...> %{a: 1}
      ...> |> Pipe.tag(:ok, Map.put(:b, 2))
      {:ok, %{a: 1, b: 2}}

  """
  defmacro tag(piped_value, tag, pipe_fragment) do
    quote do
      unquote(piped_value)
      |> fn x -> {unquote(tag), x |> unquote(pipe_fragment)} end.()
    end
  end

  @doc """
  Untags a piped value if its tagged with tag.
  Othewrise the piped value is returned as is.

      iex> use OkJose
      ...> {:ok, 22}
      ...> |> Pipe.untag(:ok)
      22

      iex> use OkJose
      ...> {:error, 33}
      ...> |> Pipe.untag(:ok)
      {:error, 33}

  """
  def untag(tagged, tag) do
    case tagged do
      {^tag, value} -> value
      x -> x
    end
  end

  @doc """
  Like `untag/2` but produces a match error if value
  is not tagged with tag.

      iex> use OkJose
      ...> {:error, 44}
      ...> |> Pipe.untag!(:ok)
      ** (CaseClauseError) no case clause matching: {:error, 44}
  """
  def untag!(tagged, tag) do
    case tagged do
      {^tag, value} -> value
    end
  end

  @doc """
  Pipes values as long as the given predicate is true

      iex> use OkJose
      ...>
      ...> [1]
      ...> |> fn x -> [5 | x] end.()
      ...> |> fn x -> [2 | x] end.()
      ...> |> fn x -> [9 | x] end.()
      ...> |> Pipe.if(fn x -> Enum.sum(x) < 6 end)
      [5, 1]

  """
  defmacro if(pipe, predicate) do
    quote do
      unquote(pipe) |>
      (unquote(__MODULE__).cond do
        value -> {unquote(predicate).(value), value}
      end)
    end
  end

  @doc """
  Pipes value when a match clause evalutes to `{true, value}`

  Because `cond/2` takes a do block with match clauses,
  be sure to suround it with parens.

  Every clause *must* return a tuple like `{boolean, payload}`
  if the boolean value is true, the payload is passed down the
  pipe, otherwise it's returned and pipe is execution is halted.

      iex> use OkJose
      ...> 1
      ...> |> fn "1" -> :one end.()
      ...> |> String.length
      ...> |> fn _ -> 99 end.()
      ...> |> (Pipe.cond do
      ...>    x when x < 2 -> {true, to_string(x)}
      ...>    x when is_atom(x) -> {true, to_string(x)}
      ...>    anything -> {false, anything}
      ...> end)
      3

  `if/2` is implemented like:

      (Pipe.cond do
        value -> {predicate.(value), value}
      end)

  """
  defmacro cond(pipe, clauses) do
    quote do
      OkJose.DefPipe.pipe_when(unquote(pipe), unquote(clauses))
    end
  end

  @doc """
  Shorthand for Pipe.tap on ok tuples

       value
       |> Pipe.tap({:ok, expr})
  """
  defmacro tap_ok(pipe, expr) do
    quote do
      unquote(__MODULE__).tap(unquote(pipe), {:ok, unquote(expr)})
    end
  end

  @doc """
  Yields its piped value into a side-effect function

  The return value of the side function is ignored.
  Continues the pipe with the original value tagged with a new atom

      iex> use OkJose
      ...> {:ok, 1}
      ...> |> Pipe.tap({:foo, IO.inspect})
      ...> |> Pipe.ok
      {:foo, 1} # side effect printed 1
  """
  defmacro tap(pipe, {tag, expr}) when is_atom(tag) do
    quote do
      unquote(pipe)
      |> case do
           value ->
             _ignored = value |> unquote(expr)
             {unquote(tag), value}
         end
    end
  end

end
