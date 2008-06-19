$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubydoctest'
require 'lines'

module RubyDocTest
  class EvaluationError < Exception
    attr_reader :source_code, :line_number, :original_exception
    def initialize(source_code, line_number, original_exception)
      @source_code, @line_number, @original_exception =
        source_code, line_number, original_exception
    end
  end
  
  class Statement < Lines
    
    attr_reader :actual_result
    
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
      @actual_result = eval(source_code, TOPLEVEL_BINDING, __FILE__, __LINE__)
    rescue SyntaxError => e
      raise EvaluationError, source_code, line_number, e
    rescue Exception => e
      if RubyDocTest.trace
        raise
      else
        raise EvaluationError, source_code, line_number, e
      end
    end
  end
end
