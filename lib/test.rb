module RubyDocTest
  # This is the top-level 'test' container that holds an optional description and one
  # or more CodeBlock objects.
  class Test
    attr_accessor :description
    attr_reader :code_blocks
    
    def initialize(description, code_blocks)
      @description, @code_blocks = description, code_blocks
    end
    
    def run
      @code_blocks.map{ |c| c.run }
    end
  end
  
end