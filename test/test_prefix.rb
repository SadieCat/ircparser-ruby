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
	PREFIXES = {
		'nick!user@host' => {
			nick: 'nick',
			user: 'user',
			host: 'host'
		},
		'nick!user' => {
			nick: 'nick',
			user: 'user',
			host: nil
		},
		'nick@host' => {
			nick: 'nick',
			user: nil,
			host: 'host'
		},
		'nick' => {
			nick: 'nick',
			user: nil,
			host: nil
		},
		'irc.example.com' => {
			nick: 'irc.example.com',
			user: nil,
			host: nil
		},
	}

	PREFIXES.each do |serialized, deserialized|
		describe 'when checking a valid prefix' do
			before do
				@prefix = IRCParser::Prefix.new serialized
			end
			it 'should consist of the correct components' do
				%i(nick user host).each do |component|
					if deserialized[component].nil?
						@prefix.send(component).must_be_nil
					else
						@prefix.send(component).must_equal deserialized[component]
					end
				end
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
