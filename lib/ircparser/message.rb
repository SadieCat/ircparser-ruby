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

module IRCParser

	# Public: Represents an IRC message.
	class Message

		# Public: Command name (e.g. PRIVMSG).
		attr_reader :command

		# Public: An array of command parameters.
		attr_reader :parameters

		# Public: The prefix of this command or nil if unprefixed.
		attr_reader :prefix

		# Public: A hash of IRCv3 message tags.
		attr_reader :tags

		# Public: Initializes a new message.
		#
		# command - Command name (e.g. PRIVMSG).
		# parameters - An array of command parameters.
		# prefix - The prefix of this command or nil if unprefixed.
		# tags - A hash of IRCv3 message tags.
		def initialize command: String.new, parameters: Array.new, prefix: nil, tags: Hash.new
			@command    = command
			@parameters = parameters
			@prefix     = prefix
			@tags       = tags
		end

		# Public: Parses an IRC message from wire form.
		#
		# line - The line to attempt to parse.
		def self.parse line
			return IRCParser::RFCWireFormat.objectify line
		end

		# Public: Serializes the message to a string.
		def to_s
			return IRCParser::RFCWireFormat.stringify self
		end
	end
end
