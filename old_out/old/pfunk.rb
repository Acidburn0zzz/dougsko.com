#!/usr/local/bin/ruby
#
# This is a class for pfunk cms
#
# Copyright (C) 2008  dougsko
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'redcloth'

# This class does two things.  When run from the command line, it
# creates a new template for you to write in.  The template has eRuby
# code in it and uses methods from this class as well to update its
# content.  The usage of these methods can be seen in the template
# below.
class Pfunk
	
	# This is the only thing you really need to change when starting
	# a new site.
	#
	# <% funk = Pfunk.new %>
	def initialize
		@title = "dougsko dot com"
	end

	# Returns everything you need between <head></head>.  It used
	# @title to set the page's title.
	#
	# <% puts funk.print_head %>
	def print_head
		head =<<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	"http://www.w3.org/TR/html4/loose.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="style.css" rel="stylesheet" type="text/css" />
<title>#{@title}</title>
</head>
EOF
	head
	end
	
	# Lists the files for the nav bar.  The glob grabs everything
	# ending in .rhtml except the index file. 
	#
	# <% funk.list_files do |full, nice| %>
	# 
	#     <% puts "<a href=\#{full}>\#{nice}</a><br />" %>
	# 
	# <% end %>
	def list_files
		Dir.glob("*.rhtml").sort.each do |file|
			next if file == "index.rhtml"
			nice_name = file.gsub(/_/, " ").gsub(/\.rhtml/, "")
			yield(file, nice_name)
		end
	end
	
	# Returns the Red Cloth formatted version of the string
	# provided.
	#
	# <% puts funk.reddify("h1. hello") %>
	def reddify(text)
		RedCloth.new(text).to_html
	end

	# Creates a template for a new page.  This is only used when run
	# from the command line.
	#
	# $ ruby pfunk.rb -c index
	def print_template(file)
		template =<<EOF
<% require 'rubygems' %>		
<% require 'pfunk' %>
<% funk = Pfunk.new %>

<% puts funk.print_head %>
<body>

<div id="heading">
	<a href="index.rhtml">#{@title}</a>
</div>

<div id="navigation">
<%
funk.list_files do |full, nice|
        puts "<a href=\#{full}>\#{nice}</a><br />"
end
%>
</div>

<% text =<<EOF
h2. TEXT GOES HERE

Ruby: Optimized for programmer happiness.

\EOF
%>

<div id="centerDoc">
<% puts funk.reddify("\#{text}") %>
</div>

<div id="footer">
	<% me = `basename \#{__FILE__}` %>
	<% puts "<a href='\#{me}.txt'>view source</a>" %>
</div>

</body>
</html>
EOF

		@filename = file + ".rhtml"
		new = File.open(@filename, "w")
		new.puts template
		new.close
	end	

	def make_docs(folder)
		@folder = folder
		Dir.chdir(@folder) do
			Dir.glob("node*.html").each do |file|
				puts file
				File.open(file, 'w+') do |f|
					f.readlines.each do |line|
						line.gsub!(/node(\d)/, "#{folder}/node\1")
						line.gsub!(/\.html/, ".rhtml")
					end
				end
				#File.rename(file, file.gsub!(/\.html/, ".rhtml"))
			end
		end
	end
end

usage = "\nUsage: ./pfunk.rb -c <name>\n\n"

if ARGV[0] == "-c"
	if ARGV[1]
		file = ARGV[1]
		funk = Pfunk.new
		funk.print_template(file)
		`ln -s #{file}.rhtml #{file}.rhtml.txt`
		exit 
	end
puts usage
end

#funk = Pfunk.new
#funk.make_docs("pftek")
