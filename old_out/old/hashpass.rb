#!/usr/local/bin/ruby
#
#
#

require 'digest/sha1'

class HashPass
	def initialize(master_pass, domain)
		@master_pass = master_pass
		@domain = domain

		@hash = Digest::SHA1.hexdigest("#{@master_pass}#{@domain}")
	end

	def print
		@hash.to_s
	end
end
