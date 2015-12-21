defmodule OkJose do

  defmacro ok({:|>, _, _} = code), do: code |> ok_pipe
  defmacro ok(code), do: code |> OkJose.Macro.piped |> ok_pipe

  defp ok_pipe(pipe) do
    [{first,_} | rest] = pipe |> Macro.unpipe
    rest 
    |> Enum.map(&case_call/1)
    |> List.insert_at(0, first)
    |> Enum.reduce(&Macro.pipe(&2, &1, 0))
  end

  defp case_call({call, _}) do
    quote do
      case do
        {:ok, value} -> value |> unquote(call)
        error -> error
      end
    end
  end
  
end
