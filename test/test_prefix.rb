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
				@text = ":#{serialized} COMMAND"
				@message = IRCParser::Message.parse @text
			end
			it 'should consist of the correct components' do
				%i(nick user host).each do |component|
					if deserialized[component].nil?
						@message.prefix.send(component).must_be_nil
					else
						@message.prefix.send(component).must_equal deserialized[component]
					end
				end
			end
			it 'should serialise back to the same text' do
				@message.to_s.must_equal @text
			end
		end
	end

	MALFORMED = [
		'nick!@',
		'!user@',
		'!@host',
		'nick!user@',
		'nick!@host',
		'!user@host',
	]

	MALFORMED.each do |prefix|
		describe 'when checking an invalid user prefix' do
			it 'should throw an IRCParser::Error when components are missing' do
				proc {
					IRCParser::Message.parse ":#{prefix} COMMAND"
				}.must_raise IRCParser::Error
			end
		end
	end
end
