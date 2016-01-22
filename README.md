# Ok Jose

A tiny library for piping function return
values on a given pattern like the erlang
idiom `{:ok, _}` and `{:error, _}` tuples.

You can also define your own pattern-matched
pipes besides `ok` and `error`.

Also, checkout [happy](https://github.com/vic/happy)

## Installation

  1. Add ok_jose to your list of dependencies in `mix.exs`:

```elixir
        def deps do
          [{:ok_jose, "~> 2.0.0"}]
        end
```

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

or alternatively:

```elixir
ok(filename |> File.read |> Poison.Parser.parse)
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

#### `ok/1`

Pipes values into functions as long as they match `{:ok, _}`

```elixir
{:ok, v} |> f |> g |> ok
```

#### `ok!/1`

Pipes values into functions but if at any point a value
does not match `{:ok, _}` raises a match error.

#### `defpipe`

Allows you to define custom pipe patterns, for example
the previous `ok!`, macro is defined like:

```elixir
defpipe ok! do
  {:ok, value} -> value
end
```

The `do` block of `defpipe` has the same form as the elixir `case` expression.

So for example, you may define a pipe to work on kittens only:

```elixir
defpipe purr do
  c = %Kitten{} -> c
  t = %Tiger{domesticated: true} -> t
end
```

## Example


###### ok math
```elixir
def dup(x), do: {:ok, x * 2}
def nop(x), do: {:error, x}

{:ok, 12} |> dup |> dup |> ok # => {:ok, 48}
{:ok, 24} |> nop |> dup |> ok # => {:error, 24}

{:ok, 24} |> dup |> ok! # => 48
{:ok, 24} |> nop |> dup |> ok! # raises
```

###### kittens

```elixir
defpipe ok_kitten do
  k = %Kitten{} -> k
  t = %Tiger{domesticated: true} -> t
end

def purr(%Kitten{}), do: "purr"
def purr(%Tiger{}), do: "PuRRR"

%Kitten{} |> purr |> ok_kitten #=> "purr"
ok_kitten( %Doggie{} |> purr ) #=> %Doggie{}


# using do/end syntax
# block executed only for matching kittens
%Kitten{} |> (ok_kitten do
  k -> purr(k)
end)
```

## About ok

I wanted name this library `ok`, but the `hex`
package name was [already taken](https://hex.pm/packages/ok). So I just wanted to make a
tribute to @josevalim.

Actually both projects are trying to solve the
same issue. But I think this one has an easier
syntax that consist of just piping to `ok`

Also, checkout [happy](https://github.com/vic/happy)

## Is it any good?

[Yes](https://news.ycombinator.com/item?id=3067434)

##### マクロス Makurosu

[Elixir macros,] The things I do for beautiful code
― George Martin, Game of Thrones

[#myelixirstatus](https://twitter.com/hashtag/myelixirstatus?src=hash)
[#FridayLiterally](http://futurice.com/blog/friday-literally)




