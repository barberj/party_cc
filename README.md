# PartyCC

CarbonCopy HTTParty responses to disk for mocking use later

## Installation

Add this line to your application's Gemfile:

    gem 'party_cc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install party_cc

## Usage

Just require gem and it will generate two files.
  ```ruby
    require 'party_cc'
  ```

The stub_request will be written down to disk in the format 'stub_#{method}\_#{path}\_#{timestamp}.txt'
The request response will be written down to disk in the format 'response_#{method}\_#{path}\_#{timestamp}.txt'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
