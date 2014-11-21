# Convert::IBM390

This is a partial port of the [Convert::IBM390](https://metacpan.org/pod/Convert::IBM390) Perl module by Geoffrey Rommel.  It includes a few extra functions meant for processing an ASCII version of a mainframe data dump, even though that's pretty easy to do.  It does not include the pack/unpackeb functions from the module, because I didn't need to implement them.  This is a port of the pure-Perl version of the module, not the C version.  Anyone who wants to add C or Java versions is welcome to do so.  

This is an extremely basic version that doesn't even include any tests (yet).  Use at your own risk.  But hey, it works on my machine.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'convert_ibm390'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install convert_ibm390

## Usage

```ruby
require 'convert/ibm390'
include Convert::IBM390

mainframe_data_file = File.open('myfile.txt', 'rb')
record_id = asc2eb(mainframe_data_file.read(3))
invoice_total = packed2num(mainframe_data_file.read(7),2)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/convert_ibm390/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
