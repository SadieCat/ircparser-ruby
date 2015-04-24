## Internet Relay Chat Message Parser

## About

This library implements a parser for the IRCv3.2 message format.

## Example Usage

### Parsing Messages

```ruby
require 'ircparser'
begin
	message = IRCParser::Message.parse '@tag1=value1;tag2;vendor1/tag3=value2;vendor2/tag4 :irc.example.com COMMAND param1 param2 :param3 param3'
	puts message.inspect
	# => #<IRCParser::Message:0x007ff774903a30 @tags={"tag1"=>"value1", "tag2"=>nil, "vendor1/tag3"=>"value2", "vendor2/tag4"=>nil}, @source=#<IRCParser::Source:0x007ff774902ec8 @type=:server, @host="irc.example.com">, @command="COMMAND", @parameters=["param1", "param2", "param3 param3"]>
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
