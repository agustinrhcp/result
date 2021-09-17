Result
==============

# Description

Result provides a way to handle the success or failure of a series of steps, inspired by the [Elm Result Type](https://package.elm-lang.org/packages/elm/core/latest/Result) and [this talk on Railway Oriented Programming](https://vimeo.com/97344498). The goal is to make it easy to chain a series of operations and require explicit handling of the success and failure cases.

While several similar gems exist (like `dry-monad`), we were unable to find one that fit our needs. This is currently battle-tested and being used in production by [Hint Health](https://www.hint.com).

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

`map` which yields the Ok value to a block. If the result is an Error, any additional steps are bypassed (the block is not executed) and the error is propogated to the end and returned.

```ruby
Result.ok(1).map { |n| n * 2 } # => Ok 1
Result.error('Bar').map { |n| n * 2 } # => Error 'Bar'
```

Similarly, you can map an Error value with `map_error`. This allows for handling and transformation.

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


## Development

Local setup:

1. `git clone git@github.com:[USERNAME]/result.git`
2. `gem install bundler:2.2.26`
3. `bundle install`
4. `rspec spec`

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/result.  All pull requests should have passing tests and include added/updated tests for any changes to code. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## See also

You might also be interested in [Dry Monad](https://dry-rb.org/gems/dry-monads/1.3/), [resonad](https://github.com/tomdalling/resonad) or [railway_operation](https://github.com/felixflores/railway_operation), among others.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
