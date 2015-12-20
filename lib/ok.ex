defmodule Ok do

  defmacro ok({:|>, _, _} = code), do: code |> ok_pipe
  defmacro ok(code), do: code |> Ok.Macro.piped |> ok_pipe

  def ok_pipe(pipe) do
    pipe |> Macro.unpipe
    |> case do
      x ->
        x |> inspect |> IO.puts
        x
      end
    nil
  end

  
end
