# VoysApi

Export calls from http://www.voys.nl.

## Installation

Add this line to your application's Gemfile:

    gem 'voys_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install voys_api

## Usage

    voys_client = VoysApi::Client.new('username', 'password')
    voys_client.export # => "\"Foreign Code\";\"Client\";\"Account...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
