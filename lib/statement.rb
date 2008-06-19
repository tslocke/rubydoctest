$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubydoctest'
require 'lines'

module RubyDocTest
  class Statement < Lines
    
    # === Test
    # 
    # doctest: A statement should parse out a '>>' irb prompt
    # >> s = RubyDocTest::Statement.new([">> a = 1"])
    # >> s.source_code
    # => "a = 1"
    #
    # doctest: More than one line should get included, if indentation so indicates
    # >> s = RubyDocTest::Statement.new([">> b = 1 +", " 1", "not part of the statement"])
    # >> s.source_code
    # => "b = 1 +\n 1"
    def source_code
      lines.first =~ /^#{Regexp.escape(indentation)}[>?]>\s(.*)$/
      ([$1] + (lines[1..-1] || [])).join("\n")
    end
    
    # === Test
    #
    # doctest: Evaluating a multi-line statement should be ok
    # >> s = RubyDocTest::Statement.new([">> b = 1 +", " 1", "not part of the statement"])
    # >> s.evaluate
    # => 2
    #
    # doctest: Evaluating a syntax error should raise a SyntaxError exception
    # >> s = RubyDocTest::Statement.new([">> b = 1 +"])
    # >> begin s.evaluate; :fail; rescue SyntaxError; :ok; end
    # => :ok
    # 
    def evaluate
      eval(source_code, TOPLEVEL_BINDING, __FILE__, __LINE__)
    rescue SyntaxError => e
      puts "Syntax error in statement on line #{line_number}:"
      puts RubyDocTest.indent(source_code)
      puts e.to_s
      puts
      exit 1
    rescue Exception => e
      puts "Exception in statement on line #{line_number}:"
      puts RubyDocTest.indent(source_code)
      puts e.backtrace

      if RubyDocTest.trace
        raise
      else
        puts e.to_s
        puts
        exit 1      
      end
    end
  end
end
