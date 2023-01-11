# Precedences

Deal with order of items in a select list of TTY-Prompt, applying the "last is the first" principle. Hence, last choice in the list will always be the first in the future.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'precedences'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install precedences

## Usage

~~~ruby
require 'precedences'

choices = [
  {name:"First choix", value: :first},
  {name:"Second choix", value: :second},
  {name:"Third choix", value: :third},
]

myfile = File.join(__dir__, 'my.precedences')

choix = precedencize(choices, myfile) do |q|
  q.question "Choose a item among:"
end

~~~

With the code above, the first time, the list will display:

~~~
> First choix
  Second choix
  Third choix
~~~

I choose "Second choix":

~~~
  First choix
> Second choix
  Third choix
~~~

The next time I use the command, the list will display:

~~~
> Second choix
  First choix
  Third choix
~~~

Then I choose "Third choix":

~~~
  Second choix
  First choix
> Third choix
~~~

The next time I use the command, the list displayed should be:

~~~
> Third choix
  Second choix
  First choix
~~~


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/precedences.

# precedences
