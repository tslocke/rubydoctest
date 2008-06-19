module RubyDocTest
  # This is the top-level 'test' container that holds an optional description and one
  # or more CodeBlock objects.
  class Test
    attr_accessor :description
    attr_reader :code_blocks, :passed
    
    def initialize(description, code_blocks)
      @description, @code_blocks = description, code_blocks
    end
    
    def pass?
      @passed = @code_blocks.all?{ |c| c.pass? }
    end
    
    def first_failed
      @code_blocks.detect{ |cb| !cb.pass? }
    end
    
    def actual_result
      first_failed.actual_result.inspect
    end
    
    def expected_result
      first_failed.expected_result
    end
  end
  
end