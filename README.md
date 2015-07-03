# DiPS ruby Client

A Ruby client for the DiPS service.

##DiPS is a Distributed Publish Subscribe service written in C#, the service and the source code can be found here:
http://pedro-ramirez-suarez.github.io/DiPS


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dipsclient'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dipsclient

## Usage
<pre>require 'dipsclient'

puts "Connecting"
client = DiPS::DiPSClient.new "ws://localhost:8888/dips"
puts "Subscribing"
client.Subscribe ("test") { |payload| puts "Received from DiPS: #{payload}" }
param = {"name"=>"pedro", "age" =>39}
puts "Publishing"
client.Publish "test", param
puts "Enter to exit"
k = gets.chomp

</pre>


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

