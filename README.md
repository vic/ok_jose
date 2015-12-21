# Ok Jose

error monad using pipes in elixir.

## Usage

```elixir
import OkJose

def foo, do: {:ok, 24}
def dup(x), do: x * 2
def nop(x), do: {:error, x}

foo |> dup |> ok # => {:ok, 48}
foo |> nop |> dup |> ok # => {:error, 24}

foo |> dup |> ok! # => 48
foo |> nop |> dup |> ok! # raises Error
```

## Installation

  1. Add ok to your list of dependencies in `mix.exs`:

```elixir
        def deps do
          [{:ok_jose, "~> 0.0.1"}]
        end
```
