defmodule OkJose.Pipe do

  @moduledoc false

  @noop []
  @same (quote do
    x -> x
  end)

  defmacro __using__(_) do
    quote do
      import OkJose.Pipe, only: [defpipe: 2]
    end
  end

  defmacro defpipe({name, _, nil}, do: patterns = [{:->, _, _} | _]) do
    bang = Atom.to_string(name) |> String.ends_with?("!")
    pipe = bang && :pipe! || :pipe
    patterns = Macro.escape(patterns)
    quote do
      defmacro unquote(name)(code) do
        OkJose.Pipe.unquote(pipe)(code, unquote(patterns))
      end

      defmacro unquote(name)(prev, code) do
        OkJose.Pipe.unquote(pipe)(prev, code, unquote(patterns))
      end
    end
  end

  def pipe!(code, patterns) do
    pipe = piped(code, patterns, @noop)
    match = {:case, [], [[do: patterns]]}
    rpipe(match, pipe)
  end

  def pipe!(prev, code, patterns) do
    case_next(code, patterns, @noop) |> rpipe(prev)
  end

  def pipe(code, patterns) do
    piped(code, patterns, @same)
  end

  def pipe(prev, code = [do: [{:->, _, _} | _]], patterns) do
    {:case, [], [code]} |> case_next(patterns, @same) |> rpipe(prev)
  end

  def pipe(prev, code, patterns) do
    case_next(code, patterns, @same) |> rpipe(prev)
  end

  defp piped(code, patterns, otherwise) do
    OkJose.Macro.piped(code)
    |> make_pipe(fn {next,0} ->
      case_next(next, patterns, otherwise)
    end)
  end

  defp case_next(next, patterns, otherwise) do
    clauses = patterns |> Enum.map(&match_cont(&1, next))
    clauses = clauses ++ otherwise
    {:case, [], [[do: clauses]]}
  end

  defp match_cont({:->, l, [pattern, value]}, next) do
    {:->, l, [pattern, rpipe(next, value)]}
  end

  defp make_pipe(pipe, needle) do
    [{first,0} | rest] = pipe |> Macro.unpipe
    rest
    |> Enum.map(needle)
    |> List.insert_at(0, first)
    |> Enum.reduce(&rpipe/2)
  end

  defp rpipe(a, b), do: quote(do: unquote(b) |> unquote(a))

end
