# GovScooper

Scoopin' up all of the metadata from Data.gov. GovScooper is a paginated harvester of the Data.gov CKAN API. It also enables you to save that metadata in a pairtree.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gov_scooper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gov_scooper

## Usage

```ruby
metadata_enumberable = DataGov::API.new.search
metadata_enumberable.length #=> 10
metadata_enumberable.map { |md| DataGov::Dataset.new(md).save_ckan_metadata }
# metadata is now saved in a pairtree directory structure based off of id
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mejackreed/GovScooper.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
