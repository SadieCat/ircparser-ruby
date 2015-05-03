# IRCParser - Internet Relay Chat Message Parser
#
#   Copyright (C) 2015 Peter "SaberUK" Powell <petpow@saberuk.com>
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

describe IRCParser::Source do
	describe 'when checking a valid server source' do
		before do
			@text = 'irc.example.com'
			@source = IRCParser::Source.new @text
		end
		it 'should consist of the correct components' do
			@source.nick.must_be_nil
			@source.user.must_be_nil
			@source.host.must_equal 'irc.example.com'
		end
		it 'should be a server not a user' do
			@source.is_server?.must_equal true
			@source.is_user?.must_equal false
		end
		it 'should serialise back to the same text' do
			@source.to_s.must_equal @text
		end
	end

	USER_MASKS = {
		'nick!user@host' => { nick: 'nick', user: 'user', host: 'host' },
		'nick!user'      => { nick: 'nick', user: 'user', host: nil    },
		'nick@host'      => { nick: 'nick', user: nil,    host: 'host' },
		'nick'           => { nick: 'nick', user: nil,    host: nil    }
	}

	USER_MASKS.each do |serialized, deserialized|
		describe 'when checking a valid user source' do
			before do
				@source = IRCParser::Source.new serialized
			end
			it 'should consist of the correct components' do
				@source.nick.must_equal deserialized[:nick]
				@source.user.must_equal deserialized[:user]
				@source.host.must_equal deserialized[:host]
			end
			it 'should be a user not a server' do
				@source.is_server?.must_equal false
				@source.is_user?.must_equal true
			end
			it 'should serialise back to the same text' do
				@source.to_s.must_equal serialized
			end
		end
	end

	describe 'when checking an invalid user source' do
		it 'should throw an IRCParser::Error when components are missing' do
			proc { IRCParser::Source.new 'nick!@' }.must_raise IRCParser::Error
			proc { IRCParser::Source.new '!user@' }.must_raise IRCParser::Error
			proc { IRCParser::Source.new '!@host' }.must_raise IRCParser::Error
			proc { IRCParser::Source.new 'nick!user@' }.must_raise IRCParser::Error
			proc { IRCParser::Source.new 'nick!@host' }.must_raise IRCParser::Error
			proc { IRCParser::Source.new '!user@host' }.must_raise IRCParser::Error
		end
	end
end
