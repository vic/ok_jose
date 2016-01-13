defmodule OkJose do

  @moduledoc """
  Easily pipe between functions returning `{:ok, _}` or `{:error, _}`.
  """

  defmacro __using__(_) do
    quote do
      use OkJose.Pipe
      import OkJose
    end
  end

  use OkJose.Pipe

  defpipe ok(value <- {:ok, value})
  defpipe ok!(value <- {:ok, value})

  defpipe error(value <- {:error, value})
  defpipe error!(value <- {:error, value})

end
