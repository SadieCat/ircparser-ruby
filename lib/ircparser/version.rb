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

	# Public: The version number which is incremented when compatibility is broken.
	VERSION_MAJOR = 0

	# Public: The version number which is incremented when new features are added.
	VERSION_MINOR = 7

	# Public: The version number which is incremented when bugs are fixed.
	VERSION_PATCH = 0

	# Public: The version label which describes the status of the build.
	VERSION_LABEL = nil

	# Public: A string which contains the current version.
	VERSION = if VERSION_LABEL.nil?
		"#{VERSION_MAJOR}.#{VERSION_MINOR}.#{VERSION_PATCH}".freeze
	else
		"#{VERSION_MAJOR}.#{VERSION_MINOR}.#{VERSION_PATCH}-#{VERSION_LABEL}".freeze
	end
end
