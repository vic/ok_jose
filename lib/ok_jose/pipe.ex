defmodule OkJose.Pipe do

  @noop []
  @same (quote do
    x -> x
  end)

  defmacro __using__(_) do
    quote do
      import OkJose.Pipe, only: [defpipe: 2]
    end
  end

  defmacro defpipe({name, _, _}, do: patterns = [{:->, _, _} | _]) do
    bang = Atom.to_string(name) |> String.ends_with?("!")
    pipe = bang && :pipe! || :pipe
    patterns = Macro.escape(patterns)
    quote do
      defmacro unquote(name)(code) do
        OkJose.Pipe.unquote(pipe)(code, unquote(patterns))
      end
    end
  end

  def pipe!(code, patterns) do
    pipe = piped(code, patterns, @noop)
    match = {:case, [], [[do: patterns]]}
    Macro.pipe(pipe, match, 0)
  end

  def pipe(code, patterns) do
    piped(code, patterns, @same)
  end

  defp piped(code, patterns, otherwise) do
    OkJose.Macro.piped(code)
    |> make_pipe(&case_next(&1, patterns, otherwise))
  end

  defp case_next({next, 0}, patterns, otherwise) do
    clauses = patterns |> Enum.map(&match_cont(&1, next))
    clauses = clauses ++ otherwise
    {:case, [], [[do: clauses]]}
  end

  defp match_cont({:->, l, [pattern, value]}, next) do
    {:->, l, [pattern, Macro.pipe(value, next, 0)]}
  end

  defp make_pipe(pipe, needle) do
    [{first,_} | rest] = pipe |> Macro.unpipe
    rest
    |> Enum.map(needle)
    |> List.insert_at(0, first)
    |> Enum.reduce(&Macro.pipe(&2, &1, 0))
  end

end
