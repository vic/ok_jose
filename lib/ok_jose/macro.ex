defmodule OkJose.Macro do
 
  def piped(code = {_, _, nil}), do: code
  
  def piped(code = {_, _, []}), do: code

  def piped({call, ctx, [arg | args]}) do
    {:|>, [], [piped(arg), {call, ctx, args}]}
  end

  def piped(code), do: code
                 
end