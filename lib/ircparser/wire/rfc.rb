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

	# Internal: Implements objectification and stringification for the RFC wire format.
	module RFCWireFormat

		# Internal: Objectifies a message from the RFC wire format to an IRCParser::Message.
		#
		# str - A String containing a message in the RFC wire format.
		def self.objectify str

			# Ruby really needs some kind of basic type checking.
			unless str.is_a? String
				raise IRCParser::Error.new(line), "message is not a string"
			end

			# Split the message up into an array of tokens.
			current_token = self.__get_token str
			components = Hash.new

			# Have we encountered IRCv3 message tags?
			components[:tags] = Hash.new
			if current_token != nil && current_token[0] == '@'
				components[:tags] = self.__objectify_tags current_token
				current_token = self.__get_token str
			end

			# Have we encountered the prefix of this message?
			if current_token != nil && current_token[0] == ':'
				components[:prefix] = self.__objectify_prefix current_token
				current_token = self.__get_token str
			end

			# The command parameter is mandatory.
			if current_token != nil
				components[:command] = current_token.upcase
				current_token = self.__get_final_token str
			else
				raise IRCParser::Error.new(line), 'message is missing the command name'
			end

			# Try to parse all of the remaining parameters.
			components[:parameters] = Array.new
			while current_token != nil
				components[:parameters] << current_token
				current_token = self.__get_final_token str
			end

			return IRCParser::Message.new components
		end

		# Internal: Stringifies a message from an IRCParser::Message to the RFC wire format.
		#
		# obj - An IRCParser::Message to stringify to the RFC wire format.
		def self.stringify obj

			# Ruby really needs some kind of basic type checking.
			unless obj.is_a? IRCParser::Message
				raise IRCParser::Error.new(obj), "message is not an IRCParser::Message"
			end

			# Stringify the tags.
			buffer = String.new
			unless obj.tags.empty?
				buffer += '@'
				buffer += self.__stringify_tags obj.tags
				buffer += ' '
			end

			# Stringify the prefix.
			unless obj.prefix.nil?
				buffer += ':'
				buffer += self.__stringify_prefix obj.prefix
				buffer += ' '
			end

			# Stringify the command.
			buffer += obj.command

			# Stringify the parameters
			buffer += self.__stringify_parameters obj.parameters

			# We're done!
			return buffer
		end

		private

		# Internal: A regular expression which matches a n!u@h mask.
		MATCH_PREFIX = /^:(?<nick>[^@!]+)  (?:!(?<user>[^@]+))?  (?:@(?<host>.+))?$/x

		# Internal: A regular expression which matches a tag.
		MATCH_TAG = /^(?<name>[^\s=]+?)(?:=(?<value>[^\s;]+))?$/

		# Internal: The characters which need to be escaped in tag values.
		TAG_ESCAPES = {
			'\\'  => '\\\\',
			';'   => '\:',
			"\s"  => '\s',
			"\r"  => '\r',
			"\n"  => '\n'
		}

		# Internal: Retrieves a space delimited token from the buffer.
		#
		# buffer - The buffer to retrieve the token from.
		def self.__get_token buffer
			return nil if buffer.empty?
			position = buffer.index ' '
			if position == nil
				token = buffer.clone
				buffer.clear
				return token
			end
			token = buffer.slice! 0...position
			position = buffer.index /\S+/
			if position == nil
				buffer.clear
			else
				buffer.slice! 0...position
			end
			return token
		end

		# Internal: Retrieves a space delimited token that may be a <trailing> parameter.
		#
		# buffer - The buffer to retrieve the token from.
		def self.__get_final_token buffer
			return nil if buffer.empty?
			if buffer[0] == ':'
				token = buffer[1..-1]
				buffer.clear
				return token
			end
			return self.__get_token buffer
		end

		# Internal: Objectifies the prefix from the RFC wire format to an IRCParser::Prefix.
		#
		# token - A String containing the prefix in the RFC wire format.
		def self.__objectify_prefix prefix
			unless MATCH_PREFIX =~ prefix
				raise IRCParser::Error.new(prefix), 'prefix is not a user mask or server name'
			end
			return IRCParser::Prefix.new nick: $~[:nick], user: $~[:user], host: $~[:host]
		end

		# Internal: Objectifies tags from the RFC wire format to a Hash.
		#
		# token - A String containing tags in the RFC wire format.
		def self.__objectify_tags token
			tags = Hash.new
			token[1..-1].split(';').each do |tag|
				if tag =~ MATCH_TAG
					name, value = $~['name'], $~['value']
					TAG_ESCAPES.each do |unescaped, escaped|
						value.gsub! escaped, unescaped
					end unless value.nil?
					tags[name] = value
				else
					raise IRCParser::Error.new(tag), 'tag is malformed'
				end
			end
			return tags
		end

		# Internal: Stringifies parameters from an Array to the RFC wire format.
		#
		# parameters - An Array to stringify to the RFC wire format.
		def self.__stringify_parameters parameters
			buffer = String.new
			parameters.each_with_index do |parameter, index|
				trailing = parameter.include? ' '
				if trailing && index != parameters.size-1
					raise IRCParser::Error.new(parameter), 'only the last parameter may contain spaces'
				end

				buffer += ' '
				if trailing || parameter.empty?
					buffer += ':'
					buffer += parameter
					break
				end
				buffer += parameter
			end
			return buffer
		end

		# Internal: Stringifies the prefix from an IRCParser::Prefix to the RFC wire format.
		#
		# tags - An IRCParser::Prefix to stringify to the RFC wire format.
		def self.__stringify_prefix prefix
			buffer = prefix.nick
			buffer += "!#{prefix.user}" unless prefix.user.nil?
			buffer += "@#{prefix.host}" unless prefix.host.nil?
			return buffer
		end

		# Internal: Stringifies tags from a Hash to the RFC wire format.
		#
		# tags - A Hash of tags to stringify to the RFC wire format.
		def self.__stringify_tags tags
			buffer = tags.map do |key, value|
				TAG_ESCAPES.each do |unescaped, escaped|
					value.gsub! unescaped, Regexp.escape(escaped)
				end unless value.nil?
				value.nil? ? key : key + '=' + value
			end.join ';'
			return buffer
		end

	end
end
