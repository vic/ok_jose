# Ok Jose

A tiny library to pipe functions that
return `{:ok, _}` or `{:error, _}` without
having you tu mess with error handling.

## Motivation

A lot of erlang libraries follow the
convention of returning `{:ok, _}` and
`{:error, _}` tuples to denote success/failure.

I just wanted an easy way to pipe 
functions in a *happy path*, that is, a
pipe that expects `{:ok, _}` to be returned
at each point. If an non-ok thing is
found at any point it breaks the rest of
the chain execution and it's returned
as result.

## Usage

Just `import OkJose`, it will provide an
`ok` macro that you can pipe to.

## Example

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

  1. Add ok to your list of dependencies in `mix.exs`:

```elixir
        def deps do
          [{:ok_jose, "~> 0.0.1"}]
        end
```

## About ok

I wanted name this library `ok`, but the `hex`
package name was [already taken](https://hex.pm/packages/ok). So I just wanted to make a
tribute to @josevalim.

Actually both projects are trying to solve the
same issue. But I think this one has an easier
syntax that consist of just piping to `ok`


## Is it any good?

[Yes](https://news.ycombinator.com/item?id=3067434)

