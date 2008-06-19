$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'statement'
require 'result'

module RubyDocTest
  # A +CodeBlock+ is a group of one or more ruby statements, followed by an optional result.
  # For example:
  #  >> a = 1 + 1
  #  >> a - 3
  #  => -1
  class CodeBlock
    attr_reader :statements, :result, :passed
    
    def initialize(statements = [], result = nil)
      @statements = statements
      @result = result
    end
    
    # === Tests
    # doctest: Single statement with result should pass
    # >> ss = [RubyDocTest::Statement.new([">> a = 1"])]
    # >> r = RubyDocTest::Result.new(["=> 1"])
    # >> cb = RubyDocTest::CodeBlock.new(ss, r)
    # >> cb.pass?
    # => true
    #
    # doctest: Single statement without result should pass by default
    # >> ss = [RubyDocTest::Statement.new([">> a = 1"])]
    # >> cb = RubyDocTest::CodeBlock.new(ss)
    # >> cb.pass?
    # => true
    #
    # doctest: Multi-line statement with result should pass
    # >> ss = [RubyDocTest::Statement.new([">> a = 1"]),
    #          RubyDocTest::Statement.new([">> 'a' + a.to_s"])]
    # >> r = RubyDocTest::Result.new(["=> 'a1'"])
    # >> cb = RubyDocTest::CodeBlock.new(ss, r)
    # >> cb.pass?
    # => true
    def pass?
      @passed ||=
        begin
          actual_results = @statements.map{ |s| s.evaluate }
          @result ? @result.matches?(actual_results.last) : true
        end
    end
    
    def actual_result
      @statements.last.actual_result
    end
    
    def expected_result
      @result.expected_result
    end
  end
end