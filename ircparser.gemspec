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

require_relative 'lib/ircparser'

Gem::Specification.new do |s|
	s.name        = 'ircparser'
	s.description = 'A standards compliant parser for the IRCv3.2 message format.'
	s.summary     = 'An IRCv3.2 message parser.'
	s.version     = IRCParser::VERSION

	s.files                 = Dir["lib/**/*.rb"] + Dir['test/**/*.rb']
	s.required_ruby_version = '>= 2.0.0'
	s.license               = 'ISC'

	s.author   = 'Peter "SaberUK" Powell'
	s.email    = 'petpow@saberuk.com'
	s.homepage = 'https://github.com/SaberUK/ircparser'

	s.add_development_dependency 'minitest', '~> 5.6', '>= 5.6.0'
	s.add_development_dependency 'tomdoc',   '~> 0.2.5'
end
