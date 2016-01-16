defmodule OkJose.Pipe do

  defmacro __using__(_) do
    quote do
      import OkJose.Pipe, only: [defpipe: 1]
    end
  end

  defmacro defpipe({name, _, [{:<-, _, [value, pattern]}]}) do
    [pattern, value] = [pattern, value] |> Enum.map(&Macro.escape/1)
    bang = Atom.to_string(name) |> String.ends_with?("!")
    pipe = bang && :pipe! || :pipe
    quote do
      defmacro unquote(name)(code) do
        OkJose.Pipe.unquote(pipe)(
          code, unquote(pattern), unquote(value))
      end
    end
  end

  def pipe!(code, pattern, value) do
    piped =
      OkJose.Macro.piped(code)
      |> make_pipe(&match_call!(&1, pattern, value))
    quote do
      case unquote(piped) do
        unquote(pattern) -> unquote(value)
      end
    end
  end

  def pipe(code, pattern, value) do
    OkJose.Macro.piped(code)
    |> make_pipe(&match_call(&1, pattern, value))
  end

  defp make_pipe(pipe, needle) do
    [{first,_} | rest] = pipe |> Macro.unpipe
    rest
    |> Enum.map(needle)
    |> List.insert_at(0, first)
    |> Enum.reduce(&Macro.pipe(&2, &1, 0))
  end

  defp match_call({call, _}, pattern, value) do
    quote do
      case do
        unquote(pattern) -> unquote(value) |> unquote(call)
        other -> other
      end
    end
  end

  defp match_call!({call, _}, pattern, value) do
    quote do
      case do
        unquote(pattern) -> unquote(value) |> unquote(call)
      end
    end
  end

end
