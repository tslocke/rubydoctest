= rubydoctest

* http://github.com/tablatom/rubydoctest

== DESCRIPTION:

Ruby version of Python's doctest tool, but a bit different.

== FEATURES/PROBLEMS:

* FIX (list of features or problems)

== SYNOPSIS:

rubydoctest comes as an executable that takes a file or directory:
	
  rubydoctest .
	rubydoctest simple.doctest

== EXAMPLE:
	
Here is an example doctest file (say called simple.doctest):
	
	# Simple test of RubyDocTest

	This is an example test

		>> 1 + 2
		=> 3

	And here's a test that will fail

		>> 1 + 2
		=> 4

	Test a some multiline statements

		>> 
			class Person
				attr_accessor :name
			end

		>> Person
		=> Person
		>> p = Person.new
		>> p.name = "Tom"
		>> p.name
		=> "Tom"


		>> "a
		b"
		=> "a\nb"

		>> 1 +
		?> 2
		=> 3

== INSTALL:

Major releases:

	sudo gem install rubydoctest

Build from source:

	git clone git://github.com/tablatom/rubydoctest.git
	cd rubydoctest
	rake manifest && rake install

== TEXTMATE BUNDLE:
	
See http://github.com/drnic/ruby-doctest-tmbundle

== LICENSE:

(The MIT License)

Copyright (c) 2008 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.