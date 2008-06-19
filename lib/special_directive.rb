$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'lines'

module RubyDocTest
  class SpecialDirective < Lines
    NAMES = ["doctest:", "!!!"]
    NAMES_FOR_RX = NAMES.map{ |n| Regexp.escape(n) }.join("|")
    
    # === Test
    #
    # doctest: The name of the directive should be detected in the first line
    # >> s = RubyDocTest::SpecialDirective.new(["doctest: Testing Stuff", "Other Stuff"])
    # >> s.name
    # => "doctest:"
    def name
      lines.first =~ /^#{Regexp.escape(indentation)}(#{NAMES_FOR_RX})/
      $1
    end
    
    # === Test
    #
    # doctest: The value of the directive should be detected in the first line
    # >> s = RubyDocTest::SpecialDirective.new(["doctest: Testing Stuff", "Other Stuff"])
    # >> s.value
    # => "Testing Stuff"
    #
    # >> s = RubyDocTest::SpecialDirective.new(["  # doctest: Testing Stuff", "  # Other Stuff"])
    # >> s.value
    # => "Testing Stuff"
    #
    # doctest: Multiple lines for the directive value should work as well
    # >> s = RubyDocTest::SpecialDirective.new(["doctest: Testing Stuff", "  On Two Lines"])
    # >> s.value
    # => "Testing Stuff\nOn Two Lines"
    def value
      $2.strip if lines.join("\n")[/^#{Regexp.escape(indentation)}(#{NAMES_FOR_RX})(.*)/m]
    end
  end
end