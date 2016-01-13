defmodule OkJose.Pipe do

  defmacro __using__(_) do
    quote do
      import OkJose.Pipe, only: [defpipe: 1]
    end
  end

  defmacro defpipe({name, _, [{:<-, _, [value, pattern]}]}) do
    pattern = Macro.escape(pattern)
    value   = Macro.escape(value)
    bang = Atom.to_string(name) |> String.ends_with?("!")
    pipe = bang && :pipe! || :pipe
    quote do
      defmacro unquote(name)(code) do
        import OkJose.Pipe, only: [{unquote(pipe), 3}]
        unquote(pipe)(code, unquote(pattern), unquote(value))
      end
    end
  end

  def pipe!(code, pattern, value) do
    piped = pipe(code, pattern, value)
    quote do
      case unquote(piped) do
        unquote(pattern) -> unquote(value)
      end
    end
  end

  def pipe({:|>, _, _} = code, pattern, value) do
    code |> run_pipe(pattern, value)
  end

  def pipe(code, pattern, value) do
    code |> OkJose.Macro.piped |> run_pipe(pattern, value)
  end

  defp run_pipe(pipe, pattern, value) do
    [{first,_} | rest] = pipe |> Macro.unpipe
    rest
    |> Enum.map(&match_call(&1, pattern, value))
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

end
