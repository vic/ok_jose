defmodule OkJose do

  @moduledoc """
  Easily pipe between functions returning `{:ok, _}` or `{:error, _}`.
  """

  import OkJose.Pipe

  defpipe ok(value <- {:ok, value})
  defpipe ok!(value <- {:ok, value})

end
