# IRCParser - Internet Relay Chat Message Parser
#
#   Copyright (C) 2015-2020 Sadie Powell <sadie@witchery.services>
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without
# fee is hereby granted, provided that the above copyright notice and this permission notice appear
# in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
# SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
# OF THIS SOFTWARE.

$LOAD_PATH.unshift "#{Dir.pwd}/lib"

require 'ircparser'
require 'minitest/autorun'

describe IRCParser::Message do
	describe 'when checking a valid message with tags and a prefix' do
		before do
			@text = '@tag1=value1;tag2;vendor1/tag3=value2;vendor2/tag4 :irc.example.com COMMAND param1 param2 :param3 param3'
			@message = IRCParser::Message.parse @text
		end
		it 'should consist of the correct components' do
			tags = { 'tag1' => 'value1', 'tag2' => '', 'vendor1/tag3' => 'value2', 'vendor2/tag4' => '' }
			parameters = [ 'param1', 'param2', 'param3 param3' ]

			_(@message.tags).must_equal tags
			_(@message.prefix).wont_be_nil
			_(@message.prefix.nick).must_equal 'irc.example.com'
			_(@message.command).must_equal 'COMMAND'
			_(@message.parameters).must_equal parameters
		end
		it 'should serialise back to the same text' do
			_(@message.to_s).must_equal @text
		end
	end

	describe 'when checking a valid message with a prefix but no tags' do
		before do
			@text = ':irc.example.com COMMAND param1 param2 :param3 param3'
			@message = IRCParser::Message.parse @text
		end
		it 'should consist of the correct components' do
			parameters = [ 'param1', 'param2', 'param3 param3' ]

			_(@message.tags).must_be_empty
			_(@message.prefix).wont_be_nil
			_(@message.prefix.nick).must_equal 'irc.example.com'
			_(@message.command).must_equal 'COMMAND'
			_(@message.parameters).must_equal parameters
		end
		it 'should serialise back to the same text' do
			_(@message.to_s).must_equal @text
		end
	end

	describe 'when checking a valid message with tags but no prefix' do
		before do
			@text = '@tag1=value1;tag2;vendor1/tag3=value2;vendor2/tag4 COMMAND param1 param2 :param3 param3'
			@message = IRCParser::Message.parse @text
		end
		it 'should consist of the correct components' do
			tags = { 'tag1' => 'value1', 'tag2' => '', 'vendor1/tag3' => 'value2', 'vendor2/tag4' => '' }
			parameters = [ 'param1', 'param2', 'param3 param3' ]

			_(@message.tags).must_equal tags
			_(@message.prefix).must_be_nil
			_(@message.command).must_equal 'COMMAND'
			_(@message.parameters).must_equal parameters
		end
		it 'should serialise back to the same text' do
			_(@message.to_s).must_equal @text
		end
	end

	describe 'when checking a valid message with tags but no prefix' do
		before do
			@text = '@tag1=value1;tag2;vendor1/tag3=value2;vendor2/tag4 COMMAND param1 param2 :param3 param3'
			@message = IRCParser::Message.parse @text
		end
		it 'should consist of the correct components' do
			tags = { 'tag1' => 'value1', 'tag2' => '', 'vendor1/tag3' => 'value2', 'vendor2/tag4' => '' }
			parameters = [ 'param1', 'param2', 'param3 param3' ]

			_(@message.tags).must_equal tags
			_(@message.prefix).must_be_nil
			_(@message.command).must_equal 'COMMAND'
			_(@message.parameters).must_equal parameters
		end
		it 'should serialise back to the same text' do
			_(@message.to_s).must_equal @text
		end
	end

	describe 'when checking a valid message with no tags, prefix or parameters' do
		before do
			@text = 'COMMAND'
			@message = IRCParser::Message.parse @text
		end
		it 'should consist of the correct components' do
			_(@message.tags).must_be_empty
			_(@message.prefix).must_be_nil
			_(@message.command).must_equal 'COMMAND'
			_(@message.parameters).must_be_empty
		end
		it 'should serialise back to the same text' do
			_(@message.to_s).must_equal @text
		end
	end

	describe 'when checking we can handle tag values properly' do
		before do
			@escaped = '\\\\\:\s\r\n'
			@unescaped = "\\;\s\r\n"
			@text = "@foo=#{@escaped} COMMAND"
		end
		it 'should escape correctly' do
			tags = { 'foo' => @unescaped }
			message = IRCParser::Message.new command: 'COMMAND', tags: tags
			_(message.to_s).must_equal @text
		end
		it 'should unescape correctly' do
			message = IRCParser::Message.parse @text
			_(message.tags['foo']).must_equal @unescaped
		end
	end

	describe 'when checking we can handle multiple consecutive spaces in a <trailing> parameter' do
		before do
			@text = 'COMMAND :param1  param1  '
			@message = IRCParser::Message.parse @text
		end
		it 'should parse the trailing parameter properly' do
			_(@message.parameters.size).must_equal 1
			_(@message.parameters[0]).must_equal 'param1  param1  '
		end
		it 'should serialize the trailing parameter properly' do
			_(@message.to_s).must_equal @text
		end
	end

	describe 'when checking we can handle a space before the command' do
		before do
			@text = ' COMMAND'
			@message = IRCParser::Message.parse @text
		end
		it 'should parse the message properly' do
			_(@message.command).must_equal 'COMMAND'
			_(@message.parameters.size).must_equal 0
		end
	end

	describe 'when checking we can handle a space after the command' do
		before do
			@text = 'COMMAND '
			@message = IRCParser::Message.parse @text
		end
		it 'should parse the message properly' do
			_(@message.command).must_equal 'COMMAND'
			_(@message.parameters.size).must_equal 0
		end
	end

	describe 'when checking we can handle an empty <trailing> parameter' do
		before do
			@text = 'COMMAND :'
			@message = IRCParser::Message.parse @text
		end
		it 'should parse the trailing parameter properly' do
			_(@message.command).must_equal 'COMMAND'
			_(@message.parameters.size).must_equal 1
			_(@message.parameters[0]).must_equal ''
		end
		it 'should serialize the trailing parameter properly' do
			_(@message.to_s).must_equal @text
		end
	end

	describe 'when checking we can handle parsing malformed tags' do
		before do
			@text = '@foo=wibble\Zwobble\\ COMMAND'
			@message = IRCParser::Message.parse @text
		end
		it 'should strip invalid and trailing escapes' do
			_(@message.tags['foo']).must_equal 'wibbleZwobble'
		end
		it 'should serialise back to a well formed value' do
			_(@message.to_s).must_equal '@foo=wibbleZwobble COMMAND'
		end
	end

	describe 'when checking we can handle serialising without creating malformed tags' do
		before do
			@tags = {
				'foo' => 'wibble\Zwobble\\'
			}
			@message = IRCParser::Message.new tags: @tags, command: 'COMMAND'
		end
		it 'should serialise without creating malformed tags' do
			_(@message.to_s).must_equal '@foo=wibble\\\\Zwobble\\\\ COMMAND'
		end
	end

	describe 'when checking we can handle serialising malformed parameters' do
		it 'should throw an IRCParser::Error when a non <trailing> parameter contains spaces' do
			_(proc {
				message = IRCParser::Message.new command: 'COMMAND', parameters: [ 'param1 param1', 'param2' ]
				message.to_s
			}).must_raise IRCParser::Error
		end
	end

	describe 'when checking we handle parsing malformed messages properly' do
		it 'should throw an IRCParser::Error when trying to parse an empty message' do
			_(proc {
				IRCParser::Message.parse ''
			}).must_raise IRCParser::Error
		end
		it 'should throw an IRCParser::Error when trying to parse an whitespace message' do
			_(proc {
				IRCParser::Message.parse '     '
			}).must_raise IRCParser::Error
		end
		it 'should throw an IRCParser::Error when trying to parse a message with tags and a prefix but no command' do
			_(proc {
				IRCParser::Message.parse '@foo;bar=baz :irc.example.com'
			}).must_raise IRCParser::Error
		end
		it 'should throw an IRCParser::Error when trying to parse a message with tags but no command' do
			_(proc {
				IRCParser::Message.parse '@foo;bar=baz'
			}).must_raise IRCParser::Error
		end
		it 'should throw an IRCParser::Error when trying to parse a message with a prefix but no command' do
			_(proc {
				IRCParser::Message.parse ':irc.example.com'
			}).must_raise IRCParser::Error
		end
	end
end
