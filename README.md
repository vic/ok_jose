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
    [{:ok_jose, "~> 3.0.0"}]
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
use OkJose

{:ok, filename}
|> File.read
|> Poison.Parser.parse
|> Pipe.ok
```

The main advantage of the macros defined by OkJose is that you dont need to learn new syntax
it's just plain old Elixir piping. It's also very easy to define your own, as they are just
case clauses.

## Usage

Read the [OkJose.Pipe docs](https://hexdocs.pm/ok_jose/OkJose.Pipe.html) for examples.

### `use OkJose`

Provides you with the `defpipe` macro and aliases `OkJose.Pipe` as `Pipe`
in the current lexical context.

##### [ok/2](https://hexdocs.pm/ok_jose/OkJose.Pipe.html#ok/2)

Passes values down the pipe as long as they macth `{:ok, value}`.

```elixir
{:ok, filename}
|> File.read
|> Poison.Parser.parse
|> Pipe.ok
```

see also 
[ok!/2](https://hexdocs.pm/ok_jose/OkJose.Pipe.html#ok!/2),
[error/2](https://hexdocs.pm/ok_jose/OkJose.Pipe.html#error/2),
[error!/2](https://hexdocs.pm/ok_jose/OkJose.Pipe.html#error!/2)


##### [defpipe/2](https://hexdocs.pm/ok_jose/OkJose.Pipe.html#defpipe/2)

Lets you define a custom pipe, for example, for working with ok
tuples and also valid ecto changesets.

```elixir
defpipe ok_or_valid do
  {:ok, value} -> value
  valid = %{valid?: true} -> valid
end


{:ok, %User{}}
|> cast(params, @required)
|> validate_required(:email)
|> Repo.insert
|> Pipe.tap({:ok, send_welcome_email}) # discard email
|> ok_or_valid
# => {:ok, inserted_user}
```

##### [if/2](https://hexdocs.pm/ok_jose/OkJose.Pipe.html#if/2),

Lets you pipe values as long as they satisfy a function predicate.
This can be useful for cases where you need to call functions and
not only pattern match on the piped values.

```elixir
[1]
|> fn x -> [5 | x] end.()
|> fn x -> [4 | x] end.()
|> fn x -> [3 | x] end.()
|> fn x -> [2 | x] end.()
|> Pipe.if(fn x -> Enum.sum(x) < 10 end)
# => [4, 5, 1]
```
##### [cond/2](https://hexdocs.pm/ok_jose/OkJose.Pipe.html#cond/2)

A more generic way to select which values can be passed down the
pipe and which cause the pipe to stop.

```elixir
{:ok, jwt_token}
|> User.find_by_jwt
|> User.new_session
|> (Pipe.cond do
  # stop piping if no user found
  nil -> {false, {:error, :invalid_token}}

  # user gets piped only if not currently logged in
  {:ok, user = %User{}} -> 
    if User.is_logged_in?(user) do
      {false, {:error, :already_logged_in}}
    else
      {true, user}
    end
end)
```

##### [and more](https://hexdocs.pm/ok_jose/OkJose.Pipe.html)

## About

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




