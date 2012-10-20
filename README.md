# Tai64

Work withTAI64 timestamps:

  http://cr.yp.to/libtai/tai64.html

TAI64 is amazing. You should be using it for your logs.


## Installation

Add this line to your application's Gemfile:

    gem 'tai64'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tai64


## Usage

    require 'tai64'

    l = Tai64.parse '@400000005083208a00ffffff'
    l.to_time.to_s # => "2012-10-20 22:06:56 UTC"

    t = Tai64::Time.new Time.at(1350770816)
    t.to_label.to_s # => "@400000005083208a000001f4"


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
