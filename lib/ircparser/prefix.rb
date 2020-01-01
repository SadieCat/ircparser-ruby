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

	# Public: Represents the prefix of an IRC message.
	class Prefix

		# Public: The hostname of this prefix or nil if no hostname was given.
		attr_reader :host

		# Public: The nickname of this user.
		attr_reader :nick

		# Public: The username of this prefix or nil if no username was given.
		attr_reader :user

		# Public: Initialises a new message prefix.
		#
		# nick - The nickname of this user.
		# user - The username of this prefix or nil if no username was given.
		# host - The hostname of this prefix or nil if no hostname was given.
		def initialize nick: nil, user: nil, host: nil
			@nick = nick
			@user = user
			@host = host
		end
	end
end
