# Ok Jose

A tiny library for piping function return
values on a given pattern like the erlang
idiom `{:ok, _}` and `{:error, _}` tuples.

You can also define your own pattern-matched
pipes besides `ok` and `error`.

## Motivation

A lot of erlang libraries follow the
convention of returning `{:ok, _}` and
`{:error, _}` tuples to denote success or failure.


This library is my try at having a beautiful syntax for a *happy pipe*, that is, a pipe that expects `{:ok, _}` tuples to be returned by each piped function.
If any piped function returns a non matched value, the remaining functions expecting an `{:ok, _}` value wont get executed.

So, for example, the following code

```elixir
filename
|> File.read()
|> case do
  {:ok, content} ->
    content |> Poison.Parser.parse()
  {:error, _} = error -> error
end
```

can be written as:

```elixir
filename |> File.read |> Poison.Parser.parse |> ok
```

## Usage

```elixir
use OkJose
```

Provides you with the following macros:
`ok`, `ok!`, `error`, `error!`


```elixir
use OkJose.Pipe
```

which provides you the `defpipe` macro.

#### `ok`

Pipes values into functions as long as they match `{:ok, _}`

```elixir
{:ok, v} |> f |> g |> ok
```

#### `ok!`

Pipes values into functions but if at any point a value
does not match `{:ok, _}` raises a match error.


#### `defpipe`

Allows you to define custom pipe patterns, for example
the previous `ok`, `ok!` macros are defined like:

```elixir
defpipe ok(value <- {:ok, value})
defpipe ok!(value <- {:ok, value})
```

## Example

```elixir

def dup(x), do: {:ok, x * 2}
def nop(x), do: {:error, x}

12 |> dup |> dup |> ok # => {:ok, 48}
24 |> nop |> dup |> ok # => {:error, 24}

24 |> dup |> ok! # => 48
24 |> nop |> dup |> ok! # raises
```

## Installation

  1. Add ok to your list of dependencies in `mix.exs`:

```elixir
        def deps do
          [{:ok_jose, "~> 1.0.0"}]
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

