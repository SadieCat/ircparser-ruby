# IRCParser - Internet Relay Chat Message Parser
#
#   Copyright (C) 2015-2019 Peter "SaberUK" Powell <petpow@saberuk.com>
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

	# Public: Parses IRC messages from a stream of data.
	class Stream

		# Public: The contents of the stream buffer.
		attr_reader :buffer

		# Public: The block which is called when a message is parsed.
		attr_reader :block

		# Public: Initialize a new stream.
		def initialize &block
			unless block.is_a? Proc
				raise TypeError, "Wrong argument type #{block.class} (expected Proc)"
			end
			@block = block
		end

		# Public: Appends data to the stream buffer.
		#
		# data - The data to append.
		def append data
			(@buffer ||= '') << data
			while @buffer.slice! /(.*?)\r?\n/
				message = IRCParser::Message.parse $1
				@block.call message
			end
		end
	end
end
