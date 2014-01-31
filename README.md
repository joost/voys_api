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
    voys_client.raw_export # => "\"Foreign Code\";\"Client\";\"Account...

    result = voys_client.export
    result.first.headers # => [:foreign_code, :client, :account__phone_number, :date, :inbound__outbound, :amount, :duration, :source, :destination, :destination_code]
    result.first[:client] # => "Client name"

You can pass the following options to raw_export and export:

    #   period_from: '2013-01-01'
    #   period_to: '2013-01-18'
    #   inboundoutbound: 0
    #   totals: 0
    #   aggregation: 0
    #   search_query: nil
    #   reset_filter: false
    #   page_number: nil

For example:

    result = voys_client.export(search_query: 'kaas')

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

(C)opyright Joopp BV - www.joopp.com