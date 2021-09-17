Result
==============

# Description

Result provides a way to handle computations that may fail. Much as it's
inspiration, the [Elm Result Type](https://package.elm-lang.org/packages/elm/core/latest/Result), allows doing further computations on top
and forces error handling.

## Installation

    gem install rb-result

Or in a `Gemfile`:

    gem 'rb-result'

## Getting Started

A new Result can be instantiated with `ok` or `error`

```ruby
require 'result'

Result.ok(:foo).ok? # => true
Result.error('Bar').ok? # => false
```

In order to transform the result you may use:

`map` which yields the Ok value to a block. If the result is an Error,
it propagates it through.

```ruby
Result.ok(1).map { |n| n * 2 } # => Ok 1
Result.error('Bar').map { |n| n * 2 } # => Error 'Bar'
```

Similarly, you can map an Error value with `map_error`

```ruby
Result.error('Bar').map_error { |error| { foo: error } } # => Error { foo: 'Bar' }
```

If the computation may fail, you want to use `then` instead. `then` also yields
the Ok value, but it's block must return a new Result.

```ruby
Result
  .ok(10)
  .then do |n|
    if n.zero?
      Result.error('Cannot devide by zero')
    else
      Result.ok(10 / n)
    end
  end
```

Once we are done with all computations we want to get our Result value. For
that we need to chain two methods, one for each possibility and handle
our values there.

```ruby
Result.ok(10)
  .when_ok { |n| n * 2 }
  .when_error { |error| "Something failed: #{error}" }
  # => 20
```

## Example

A silly implementation of a signup using Result could look like this:

```ruby
module Signup
  def self.create(username)
    Result
      .ok(username)
      .map { |username| format_username(username) }
      .then { |username| validate_username_is_not_taken(username) }
      .then { |username| create_new_account(username) }
      .map { |account| send_welcome_email(account) }
  end

  def self.format_username(username)
    username.trim.downcase
  end

  def self.validate_username_is_not_taken(username)
    if Account.username_taken?(username)
      Result.error('Username is already taken')
    else
      Result.ok(username)
    end
  end

  def self.create_new_account(username)
    new_account = Account.new(username)

    if new_account.save
      Result.ok(new_account)
    else
      Result.error('Account couldn\'t be created')
    end
  end

  def self.send_welcome_email(account)
    acocunt.send_welcome_email
    # We need to make sure the account is returned so it becomes the
    # Ok value for the next Result
    account
  end
end
```

And the way we deal with the returned value, for instance on a controller endpoint:

```ruby
def create
  Signup
    .create(params[:username])
    .when_ok { |account| render json: account.to_json }
    .when_error { |error| render json: { message: error }, status: 422 }
end
```
