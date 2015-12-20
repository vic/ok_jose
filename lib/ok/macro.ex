defmodule Ok.Macro do
 
  def piped(code) 
  when not is_tuple(code) 
  or not tuple_size(code) == 3 do
    code
  end

  def piped(code = {_, _, nil}), do: code
  def piped(code = {_, _, []}), do: code
  def piped({call, ctx, [arg | args]}) do
    {:|>, [], [piped(arg), {call, ctx, args}]}
  end
                 
end