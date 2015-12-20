# Ok

error monad using pipes in elixir.

## Usage

```elixir
def foo, do: {:ok, 24}
def dup(x), do: x * 2
def nop(x), do: {:error, x}

foo |> dup |> ok # => {:ok, 48}
foo |> nop |> dup |> ok # => {:error, 24}

foo |> dup |> ok! # => 48
foo |> nop |> dup |> ok! # raises Error
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add ok to your list of dependencies in `mix.exs`:

```elixir
        def deps do
          [{:ok, "~> 0.0.1"}]
        end
```

  2. Ensure ok is started before your application:

```elixir
        def application do
          [applications: [:ok]]
        end
```