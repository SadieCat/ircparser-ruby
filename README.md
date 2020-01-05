## Internet Relay Chat Message Parser

## About

This library implements a parser for the IRCv3 message format.

## Example Usage

### Parsing Messages

```ruby
require 'ircparser'
begin
	message = IRCParser::Message.parse '@tag1=value1;tag2;vendor1/tag3=value2;vendor2/tag4 :irc.example.com COMMAND param1 param2 :param3 param3'
	puts message.inspect
	# => <IRCParser::Message:0x00007fe0f11f1ad8 @command="COMMAND", @parameters=["param1", "param2", "param3 param3"], @prefix=#<IRCParser::Prefix:0x00007fe0f2120068 @nick="irc.example.com", @user=nil, @host=nil>, @tags={"tag1"=>"value1", "tag2"=>"", "vendor1/tag3"=>"value2", "vendor2/tag4"=>""}>
rescue IRCParser::Error => e
	puts "ERROR: #{e.message} -- #{e.value}"
end
```

Alternatively, you can use the `IRCParser::Stream` class to directly parse data received from a network socket like this:

```ruby
require 'ircparser'
begin
	stream = IRCParser::Stream.new do |message|
		puts message.inspect
	end
	stream.append "@tag1=value1;tag2;vendor1/tag3=value2;vendor2/tag4 :ir"
	stream.append "c.example.com COMMAND param1 param2 :param3 param3\n\r"
	# => <IRCParser::Message:0x00007fe0f18b9988 @command="COMMAND", @parameters=["param1", "param2", "param3 param3"], @prefix=#<IRCParser::Prefix:0x00007fe0f18b9dc0 @nick="irc.example.com", @user=nil, @host=nil>, @tags={"tag1"=>"value1", "tag2"=>"", "vendor1/tag3"=>"value2", "vendor2/tag4"=>""}>
rescue IRCParser::Error => e
	puts "ERROR: #{e.message} -- #{e.value}"
end
```

### Creating Messages

```ruby
require 'ircparser'
message = IRCParser::Message.new command: 'PRIVMSG'
message.parameters << '#example'
message.parameters << 'Hello, World!'
puts message.to_s
# => PRIVMSG #example :Hello, World!
end
```
## License

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee
is hereby granted, provided that the above copyright notice and this permission notice appear in all
copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
