defmodule OkJose do

  @moduledoc """
  Easily pipe between functions returning `{:ok, _}` or `{:error, _}`.
  """

  @doc """
      use OkJose

  This will require `OkJose.Pipe` as `Pipe` on your lexical context.
  """
  defmacro __using__(_) do
    quote do
      require OkJose.DefPipe
      require OkJose.Pipe, as: Pipe

      import OkJose.Pipe, only: [ok: 1, ok!: 1,
                                 ok: 2, ok!: 2,
                                 error: 1,
                                 error: 2, error!: 2,
                                 defpipe: 2]
      import OkJose
    end
  end

  @doc """
  See `OkJose.Pipe.if/2`
  """
  defmacro pipe_if(pipe, pred) do
    quote do
      OkJose.Pipe.if(unquote(pipe), unquote(pred))
    end
  end

  @doc """
  See `OkJose.Pipe.cond/2`
  """
  defmacro pipe_cond(pipe, clauses) do
    quote do
      OkJose.Pipe.cond(unquote(pipe), unquote(clauses))
    end
  end

end
