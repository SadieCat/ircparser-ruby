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

	# Public: Represents an IRC message.
	class Message

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

		# Public: Command name (e.g. PRIVMSG).
		attr_reader :command

		# Public: An array of command parameters.
		attr_reader :parameters

		# Public: The source of this command or nil if unsourced.
		attr_reader :source

		# Public: A hash of IRCv3 message tags.
		attr_reader :tags

		# Public: Initialize a new message.
		def initialize command: String.new, parameters: Array.new, source: nil, tags: Hash.new
			@command    = command
			@parameters = parameters
			@source     = source
			@tags       = tags
		end

		# Public: Parses an IRC message from network form.
		#
		# line - The line to attempt to parse.
		def self.parse line

			# Ruby really needs some kind of basic type checking.
			raise IRCParser::Error.new(line), "line is not a string" unless line.is_a? String

			# Split the message up into an array of tokens.
			buffer = line.clone
			current_token = __get_token buffer
			components = Hash.new

			# Have we encountered IRCv3 message tags?
			components[:tags] = Hash.new
			if current_token != nil && current_token[0] == '@'
				components[:tags] = __parse_tags current_token
				current_token = __get_token buffer
			end

			# Have we encountered the source of this message?
			if current_token != nil && current_token[0] == ':'
				components[:source] = IRCParser::Source.new current_token[1..-1]
				current_token = __get_token buffer
			end

			# The command parameter is mandatory.
			if current_token != nil
				components[:command] = current_token.upcase
				current_token = __get_final_token buffer
			else
				raise IRCParser::Error.new(line), 'message is missing the command name'
			end

			# Try to parse all of the remaining parameters.
			components[:parameters] = Array.new
			while current_token != nil
				components[:parameters] << current_token
				current_token = __get_final_token buffer
			end

			return IRCParser::Message.new components
		end


		# Public: Serializes the message to a string.
		def to_s
			buffer = String.new

			# Serialize the tags.
			unless tags.empty?
				buffer += '@'
				buffer += __serialize_tags
				buffer += ' '
			end

			# Serialize the source.
			unless source.nil?
				buffer += ':'
				buffer += source.to_s
				buffer += ' '
			end

			# Serialize the command.
			buffer += command

			# Serialize the parameters
			buffer += __serialize_parameters

			# We're done!
			return buffer
		end

		private

		# Internal: Retrieves a space delimited token from the buffer.
		#
		# data - The buffer to retrieve the token from.
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
			buffer.slice! 0...position
			return token
		end

		# Internal: Retrieves a space delimited token that may be a <trailing> parameter.
		#
		# data - The buffer to retrieve the token from.
		def self.__get_final_token buffer
			return nil if buffer.empty?
			if buffer[0] == ':'
				token = buffer[1..-1]
				buffer.clear
				return token
			end
			return __get_token buffer
		end

		# Internal: Parse tags from network form to a Hash.
		#
		# token - A list of tags in network form.
		def self.__parse_tags token
			tags = Hash.new
			token[1..-1].split(';').each do |tag|
				if tag =~ MATCH_TAG
					name, value = $~['name'], $~['value']
					TAG_ESCAPES.each do |unescaped, escaped|
						value.gsub! escaped, unescaped
					end unless value.nil?
					tags[name] = value
				else
					raise IRCParser::Error.new(tag), "tag is malformed"
				end
			end
			return tags
		end

		# Internal: Serializes parameters from an Array to network form.
		def __serialize_parameters
			buffer = String.new
			@parameters.each_with_index do |parameter, index|
				buffer += ' '
				if parameter.include? ' '
					buffer += ':'
					buffer += parameters[index..-1].join ' '
					break
				end
				buffer += parameter
			end
			return buffer
		end

		# Internal: Serializes tags from a Hash to network form.
		def __serialize_tags
			buffer = @tags.dup.map do |key, value|
				TAG_ESCAPES.each do |unescaped, escaped|
					value.gsub! unescaped, Regexp.escape(escaped)
				end unless value.nil?
				value.nil? ? key : key + '=' + value
			end.join ';'
			return buffer
		end
	end
end
