# Ok Jose

[![help maintain this lib](https://img.shields.io/badge/looking%20for%20maintainer-DM%20%40vborja-663399.svg)](https://twitter.com/vborja)


A tiny library for piping values on a given pattern like the erlang idiom `{:ok, _}` and `{:error, _}` tuples.

You can also define your own pattern-matched pipes besides `ok` and `error`.

Besides `ok_jose` I've made a couple more of related macro libraries
that might be related (or useful depending on your needs and taste):

- [happy](https://github.com/vic/happy) from back before `with` landed elixir 1.2
- [pit](https://github.com/vic/pit) a kind of pipeable `with`.

## Installation

  1. Add ok_jose to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [{:ok_jose, "~> 2.1.0"}]
  end
```

## Motivation

A lot of erlang libraries follow the convention of returning `{:ok, _}` and `{:error, _}` tuples to denote 
the success or failure of a computation. It's my opinion that more people should embrace this convention
on their code, and this library helps by making it easier to pipe values by unwrapping them from the
tagged tuples.


This library is my try at having a beautiful syntax for a *happy pipe*, that is, a pipe that expects `{:ok, _}`
tuples to be returned by each piped function.
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
{:ok, filename}
|> File.read
|> Poison.Parser.parse
|> ok
```

The main advantage of the macros defined by OkJose is that you dont need to learn new syntax
it's just plain old Elixir piping. It's also very easy to define your own, as they are just
case clauses.

## Usage

### `use OkJose`

Provides you with the following macros:

##### `ok/2`

Pipes values into functions as long as they match `{:ok, _}`

```elixir
{:ok, v} |> f |> g |> ok
```

##### `ok!/2`

Pipes values into functions but if at any point a value
does not match `{:ok, _}` raises a match error.

##### `error/2` and `error!/2`

Work exactly as the previous examples, but for tuples tagged as `:error`.

### `use OkJose.Pipe`

#### `defpipe`

This module lets you define your own pipes, actually the
previous `ok` pipe is defined like the following. Any
value not matching is just piped as-is down the pipe.

```elixir
defpipe ok do
  {:ok, value} -> value
end
```

However if the pipe name ends with an exclamation mark,
and no clause matches, an error will be raise just as with
any function not matching on its arguments.

```elixir
defpipe ok! do
  {:ok, value} -> value
end
```


With these you can define a pipe for working on common values
like ecto models and changesets.

```elixir
defpipe ok_or_valid do
  {:ok, value} -> value
  changeset = %{valid?: true}  -> changeset
end
```

This way you can pipe ok values or valid changesets like:

```elixir
{:ok, %User{}}
|> cast(params, @required)
|> put_change(:name, "John")
|> Repo.insert
|> update_jwk_token
|> ok_or_valid
```

You can also define pipes that for values based on a predicate
instead of just a pattern match. For example, if you need to
call some function to determine if the value is safe to be
passed through the rest of your pipe.

The `OkJose.pipe_when` macro takes a block of patterns and
expects each to return a form like `{true, value}` or `{false, value}`
The first boolean value on the tuple tells if the payload
is to be passed down the pipe or if the pipe must suspend execution.

This way you can use negative matches, for example
the following pipe will only let safe pets to be given to functions:

The predicate `?`-ending form of `defpipe` is just sugar for `pipe_when`

```elixir
@dangerous [Lion, Wolf, Cocodrile]

defpipe pet_safe? do
  pet = %{__struct__: mod} when not mod in @dangerous -> 
    {true, pet}
  anything ->
    {false, pet}
end
```

And you can use them by just adding to the end of the pipe

```elixir
{:ok, pet}
|> take_out
|> go_to(:park)
|> play_with(:kids)
|> pet_safe?
```

## About ok

OkJose was born a while ago, back before we had Elixir 1.0, and before Elixir had its
own `with` form to deal with this kind of problems. There are a lot of other libraries
for dealing with tagged tuples and in general for monads in elixir. I'd recommend you
to checkout these in particular: 

- [`ok`](https://hex.pm/packages/ok) 
  A growing library, also has a list of alternatives at their Readme.

- [`happy`](https://github.com/vic/happy)
  Work on OkJose leadme to creating happy and later [`happy_with`](https://github.com/vic/happy_with)
  They are just a bit less-pipeable than OkJose, and more on the spirit of Elixir's `with`
  
- [`pit`](https://github.com/vic/pit)
  A weird one, for transforming and matching data at every pipe step. 
  I dont know what I was thinking while doing it, but maybe it can be of use to someone.

## Is it any good?

[Yes](https://news.ycombinator.com/item?id=3067434)

Take a look at the tests for more code examples.

##### マクロス Makurosu

[[Elixir macros](https://github.com/h4cc/awesome-elixir#macros),] The things I do for beautiful code
― George Martin, Game of Thrones

[#myelixirstatus](https://twitter.com/hashtag/myelixirstatus?src=hash)
[#FridayLiterally](http://futurice.com/blog/friday-literally)




