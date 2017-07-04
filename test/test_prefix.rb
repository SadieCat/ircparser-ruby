# IRCParser - Internet Relay Chat Message Parser
#
#   Copyright (C) 2015-2017 Peter "SaberUK" Powell <petpow@saberuk.com>
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

describe IRCParser::Prefix do
	describe 'when checking a valid server prefix' do
		before do
			@text = 'irc.example.com'
			@prefix = IRCParser::Prefix.new @text
		end
		it 'should consist of the correct components' do
			@prefix.nick.must_be_nil
			@prefix.user.must_be_nil
			@prefix.host.must_equal 'irc.example.com'
		end
		it 'should be a server not a user' do
			@prefix.is_server?.must_equal true
			@prefix.is_user?.must_equal false
		end
		it 'should serialise back to the same text' do
			@prefix.to_s.must_equal @text
		end
	end

	USER_MASKS = {
		'nick!user@host' => { nick: 'nick', user: 'user', host: 'host' },
		'nick!user'      => { nick: 'nick', user: 'user', host: nil    },
		'nick@host'      => { nick: 'nick', user: nil,    host: 'host' },
		'nick'           => { nick: 'nick', user: nil,    host: nil    }
	}

	USER_MASKS.each do |serialized, deserialized|
		describe 'when checking a valid user prefix' do
			before do
				@prefix = IRCParser::Prefix.new serialized
			end
			it 'should consist of the correct components' do
				@prefix.nick.must_equal deserialized[:nick]
				@prefix.user.must_equal deserialized[:user]
				@prefix.host.must_equal deserialized[:host]
			end
			it 'should be a user not a server' do
				@prefix.is_server?.must_equal false
				@prefix.is_user?.must_equal true
			end
			it 'should serialise back to the same text' do
				@prefix.to_s.must_equal serialized
			end
		end
	end

	describe 'when checking an invalid user prefix' do
		it 'should throw an IRCParser::Error when components are missing' do
			proc { IRCParser::Prefix.new 'nick!@' }.must_raise IRCParser::Error
			proc { IRCParser::Prefix.new '!user@' }.must_raise IRCParser::Error
			proc { IRCParser::Prefix.new '!@host' }.must_raise IRCParser::Error
			proc { IRCParser::Prefix.new 'nick!user@' }.must_raise IRCParser::Error
			proc { IRCParser::Prefix.new 'nick!@host' }.must_raise IRCParser::Error
			proc { IRCParser::Prefix.new '!user@host' }.must_raise IRCParser::Error
		end
	end
end
