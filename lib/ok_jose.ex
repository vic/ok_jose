defmodule OkJose do

  @moduledoc """
  Easily pipe between functions returning `{:ok, _}` or `{:error, _}`.
  """

  defmacro __using__(_) do
    quote do
      import OkJose.Pipe
      import OkJose.DefPipe, only: [defpipe: 2, pipe_when: 2]
    end
  end

end
