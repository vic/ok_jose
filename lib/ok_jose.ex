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

  defpipe ok do
    {:ok, value} -> value
  end

  defpipe ok! do
    {:ok, value} -> value
  end

  defpipe error do
    {:error, value} -> value
  end

  defpipe error! do
    {:error, value} -> value
  end

end
