defmodule OkJose.DefPipe do

  @moduledoc false

  @noop []
  @same (quote do
    x -> x
  end)

  defmacro __using__(_) do
    quote do
      import OkJose.DefPipe, only: [defpipe: 2, pipe_when: 2]
    end
  end

  defmacro defpipe({name, _, nil}, do: patterns = [{:->, _, _} | _]) do
    last = Atom.to_string(name) |> String.at(-1)
    def_pipe(last, name, Macro.escape(patterns))
  end

  defp def_pipe("!", name, patterns), do: def_pipe(:pipe!, name, patterns)
  defp def_pipe("?", name, patterns), do: def_pipe(:pipe?, name, patterns)
  defp def_pipe(x, name, patterns) when is_binary(x), do: def_pipe(:pipe, name, patterns)

  defp def_pipe(:pipe?, name, patterns) do
    quote do
      defmacro unquote(name)(code) do
        OkJose.DefPipe.pipe?(code, unquote(patterns))
      end
    end
  end

  defp def_pipe(pipe, name, patterns) when pipe == :pipe or pipe == :pipe! do
    quote do
      defmacro unquote(name)(code) do
        OkJose.DefPipe.unquote(pipe)(code, unquote(patterns))
      end

      defmacro unquote(name)(prev, code) do
        OkJose.DefPipe.unquote(pipe)(prev, code, unquote(patterns))
      end
    end
  end

  defmacro pipe_when(code, do: patterns = [{:->, _, _} | _]) do
    pipe?(code, patterns)
  end

  def pipe?(code, patterns) do
    code
    |> OkJose.Macro.piped
    |> make_pipe(fn {next, 0} ->
      quote do
        case do unquote(patterns) end
        |> case do
             {false, value} -> value
             {true, value} -> value |> unquote(next)
           end
      end
    end)
  end

  def pipe!(code, patterns) do
    pipe = piped(code, patterns, @noop)
    match = {:case, [], [[do: patterns]]}
    rpipe(match, pipe)
  end

  def pipe!(prev, code = [do: [{:->, _, _} | _]], patterns) do
    {:case, [], [code]} |> case_next(patterns, @noop) |> rpipe(prev)
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
