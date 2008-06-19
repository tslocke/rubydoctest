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
    attr_reader :statements, :result
    
    def initialize(statements = [], result = nil)
      @statements = statements
      @result = result
    end
    
    def run
      actual_results = @statements.map{ |s| s.evaluate }
      @result ? @result.matches?(actual_results.last) : true
    end
  end
end