= Ruby DocTest

Official repository:
	* http://github.com/tablatom/rubydoctest

Wiki documentation:
	* http://github.com/tablatom/rubydoctest/wikis

== Description:

Ruby version of Python's doctest tool, but a bit different. Ruby DocTest
allows you to:

	1. Write tests in irb format and keep them as comments next to your Ruby code.
	2. Write markdown documents with irb format tests embedded in them.

== Synopsis:

rubydoctest comes as an executable that takes a list of files:
	
  rubydoctest lib/*.rb
	rubydoctest simple.doctest

== Examples:
	
Here is how you might use RubyDocTest within a ruby source file (say called five.rb):

	# doctest: Add 5 and 5 to get 10
	# >> five_and_five
	# => 10
	def five_and_five
	  5 + 5
	end

Here is an example doctest file (say called simple.doctest):
	
	# Simple test of RubyDocTest

	This is an example test

		>> 1 + 2
		=> 3

	And here's a test that will fail

		>> 1 + 2
		=> 4

See the doc directory of this project for more .doctest examples and documentation.

== Installation:

Major releases:

	sudo gem install rubydoctest

Build from source:

	git clone git://github.com/tablatom/rubydoctest.git
	cd rubydoctest
	rake manifest:refresh && rake install

== Testing DocTest:
	
Ruby DocTest uses itself to test and document itself.

	rake test:doctest
	
In development of Ruby DocTest, there is an autotest system in-built
using script/rstakeout

	rake test:doctest:auto

== TextMate Bundle:
	
See http://github.com/drnic/ruby-doctest-tmbundle

== License:

(The MIT License)

Copyright (c) 2008 Tom Locke, Nic Williams, Duane Johnson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.