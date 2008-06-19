module RubyDocTest
  # A +CodeBlock+ is a group of one or more ruby statements, followed by an optional result.
  # For example:
  #  >> a = 1 + 1
  #  >> b = a - 2
  #  => 0
  class CodeBlock
    attr_reader :statements, :result
    
    def initialize(statements = [], result = nil)
      @statements = statements
      @result = result
    end
    
    def run
      @statements.map{ |s| s.evaluate }
    end
  end
end