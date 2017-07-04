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

module IRCParser

	# Public: Represents the prefix of an IRC message.
	class Prefix

		# Internal: A regular expression which matches a n!u@h mask.
		MATCH_USER = /^(?<nick>[^@!]+)     (?:!(?<user>[^@]+))?     (?:@(?<host>.+))?$/x

		# Internal: A regular expression which matches a server name.
		MATCH_SERVER = /^(?<host>\S+\.\S+)$/

		# Public: The hostname of this prefix.
		attr_reader :host

		# Public: The nickname of this user or nil if the prefix is a server.
		attr_reader :nick

		# Public: The username of this user or nil if the prefix is a server.
		attr_reader :user

		# Public: Initialise a new message prefix from a serialised prefix.
		#
		# prefix - Either a n!u@h mask or a server name.
		def initialize prefix
			if MATCH_SERVER =~ prefix
				@type = :server
				@host = $~[:host]
			elsif MATCH_USER =~ prefix
				@type = :user
				@nick = $~[:nick]
				@user = $~[:user]
				@host = $~[:host]
			else
				raise IRCParser::Error.new(prefix), 'prefix is not a user mask or server name'
			end
		end

		# Public: Whether this prefix represents a user.
		def is_user?
			return @type == :user
		end

		# Public: Whether this prefix represents a server.
		def is_server?
			return @type == :server
		end

		# Public: The name by which this prefix can be identified.
		def name
			return is_user? ? @nick : @host
		end

		# Public: serialises this prefix to the serialised form.
		def to_s
			if is_user?
				buffer = @nick
				buffer += "!#{@user}" unless @user.nil?
				buffer += "@#{@host}" unless @host.nil?
				return buffer
			end
			return @host
		end
	end
end
