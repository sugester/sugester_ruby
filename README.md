# Sugester

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/sugester`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sugester'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sugester

## Usage

There are to ways of using this gem:

```ruby
# config/initializers/sugester.rb
Sugester.init_singleton("sugester_gem_secret")

# anywhere in your app
Sugester.activity(client_id, 'activity_name')
Sugester.property(client_id, {
  'property_name1' => 'foo',
  'property_name2' => 42
})

```

```ruby
# config/initializers/sugester.rb

ACCOUNT_1 = Sugester::SugesterQueue.new("sugester_gem_secret_1")
ACCOUNT_2 = Sugester::SugesterQueue.new("sugester_gem_secret_2")

# anywhere in your app
ACCOUNT_1.activity(client_id_for_account1, 'activity_name')
ACCOUNT_1.property(client_id_for_account1, {
  'property_name1' => 'foo',
  'property_name2' => 42
})


ACCOUNT_2.activity(client_id_for_account2, 'activity_name')
ACCOUNT_2.property(client_id_for_account2, {
  'property_name1' => 'foo',
  'property_name2' => 42
})
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sugester/sugester.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

