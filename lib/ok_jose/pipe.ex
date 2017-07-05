defmodule OkJose.Pipe do

  import OkJose.DefPipe, only: [defpipe: 2]

  defmacro __using__(_) do
    quote do
      require OkJose.Pipe, as: Pipe
      import OkJose.DefPipe, only: [defpipe: 2]
    end
  end

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
