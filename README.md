# AzureEnum

This Ruby Gem assists in enumeration of Office 365 or Exchange on-premise federated domains. This can allow you to identify domains associated with a business, not easily identified through traditional means. The examples below demonstrate how output can be interesting.

The time this process takes can vary from a few seconds to a few minutes depending on the hosting server.
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'azure_enum'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install azure_enum

## Usage

You can use this gem from within an application:

```
require "azure_enum"
x = AzureEnum.federated("lolware.net")
=> ["lolzware.onmicrosoft.com", "lolware.net"]
```

Or by installing and running the binary:
```
bundle exec ./bin/azure_enum lolware.net
Please wait while the given domain is enumerated.
lolzware.onmicrosoft.com
lolware.net
```

## Examples

The following examples against some random domains demonstrate the tools capabilities.

```
$ azure_enum afl.com.au
Please wait while the given domain is enumerated.
afl.com.au
aflnt.com.au
ntthunder.com.au
aflgoulburnmurray.com.au
aflwesterndistrict.com.au
aflgippsland.com.au
aflyarraranges.com.au

$ azure_enum kmart.com.au
Please wait while the given domain is enumerated.
kmart.com.au
KASAsia.com

$ azure_enum microsoft.com
Please wait while the given domain is enumerated.
corp.webtv.net
microsoft.onmicrosoft.com
surface.com
bungie.com
navic.tv
middleeast.corp.microsoft.com
wingroup.windeploy.ntdev.microsoft.com
exchangecalendarsharing.com
redmond.corp.microsoft.com
northamerica.corp.microsoft.com
bing.com
corp.microsoft.com
placeware.com
(snip large list)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/technion/azure_enum.
Sometimes you get this output:

    Unknown key: Max-Age = 31536000

It seems to be a known bug in HTTPClient.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
