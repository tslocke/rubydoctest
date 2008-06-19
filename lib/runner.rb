$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubydoctest'
require 'statement'
require 'result'
require 'special_directive'
require 'code_block'

module RubyDocTest
  class Runner
    attr_reader :groups, :blocks, :tests

    # The evaluation mode, either :doctest or :ruby.
    #
    # Modes:
    #   :doctest
    #     - The the Runner expects the file to contain text (e.g. a markdown file).
    #       In addition, it assumes that the text will occasionally be interspersed
    #       with irb lines which it should eval, e.g. '>>' and '=>'.
    #
    #   :ruby
    #     - The Runner expects the file to be a Ruby source file.  The source may contain
    #       comments that are interspersed with irb lines to eval, e.g. '>>' and '=>'.
    attr_accessor :mode
    
    
    # === Tests
    # 
    # doctest: Runner mode should default to :doctest and :ruby from the filename
    # >> r = RubyDocTest::Runner.new("", "test.doctest")
    # >> r.mode
    # => :doctest
    #
    # >> r = RubyDocTest::Runner.new("", "test.rb")
    # >> r.mode
    # => :ruby
    #
    # doctest: The src_lines should be separated into an array
    # >> r = RubyDocTest::Runner.new("a\nb\n", "test.doctest")
    # >> r.instance_variable_get("@src_lines")
    # => ["a", "b", ""]
    def initialize(src, file_name, initial_mode = nil)
      @src, @file_name = src, file_name
      @mode = initial_mode || (File.extname(file_name) == ".rb" ? :ruby : :doctest)
      
      @src_lines = src.split("\n")
      @groups, @blocks = [], []
    end

    def run
      run_file
      print_report
    end

    def run_file
      eval(@src, TOPLEVEL_BINDING) if @mode == :ruby
      @groups = read_groups
      @blocks = organize_blocks
      @tests = organize_tests
      @tests.map{ |t| t.run }
    end
    
    # === Tests
    # 
    # doctest: Non-statement lines get ignored while statement / result lines are included
    #          Default mode is :doctest, so non-irb prompts should be ignored.
    # >> r = RubyDocTest::Runner.new("a\nb\n >> c = 1\n => 1")
    # >> groups = r.read_groups
    # >> groups.size
    # => 2
    #
    # doctest: Group types are correctly created
    # >> groups.map{ |g| g.class }
    # => [RubyDocTest::Statement, RubyDocTest::Result]
    #
    # doctest: A ruby document can have =begin and =end blocks in it
    # >> r = RubyDocTest::Runner.new(<<-RUBY, "test.rb")
    #    some_ruby_code = 1
    #    =begin
    #     this is a normal ruby comment
    #     >> z = 10
    #     => 10
    #    =end
    #    more_ruby_code = 2
    #    RUBY
    # >> groups = r.read_groups
    # >> groups.size
    # => 2
    # >> groups.map{ |g| g.lines.first }
    # => [" >> z = 10", " => 10"]
    def read_groups(src_lines = @src_lines, mode = @mode)
      groups = []
      src_lines.each_with_index do |line, index|
        case mode
        when :ruby
          case line
          
          # Beginning of a multi-line comment section
          when /^=begin/
            groups +=
              # Get statements, results, and directives as if inside a doctest
              read_groups(src_lines[index...(src_lines.size)], :doctest_with_end)
          
          else
            groups << g if g = match_group("\\s*#\\s*", src_lines, index)
          
          end
        when :doctest
          groups << g if g = match_group("\\s*", src_lines, index)
          
        when :doctest_with_end
          break if line =~ /^=end/
          groups << g if g = match_group("\\s*", src_lines, index)
          
        end
      end
      groups
    end
    
    def match_group(prefix, src_lines, index)
      case src_lines[index]
      
      # An irb '>>' marker after a '#' indicates an embedded doctest
      when /^(#{prefix})[>?]>(\s|\s*$)/
        Statement.new(src_lines, index)
      
      # An irb '=>' marker after a '#' indicates an embedded result
      when /^(#{prefix})=>\s/
        Result.new(src_lines, index)
      
      # Whenever we match a directive (e.g. 'doctest'), add that in as well
      when /^(#{prefix})(#{SpecialDirective::NAMES_FOR_RX})(.*)$/
        SpecialDirective.new(src_lines, index)
      
      else
        nil
      end
    end
    
    # === Tests
    # 
    # doctest: The organize_blocks method should separate Statement, Result and SpecialDirective
    #          objects into CodeBlocks.
    # >> r = RubyDocTest::Runner.new(">> t = 1\n>> t + 2\n=> 3\n>> u = 1", "test.doctest")
    # >> r.run_file
    # 
    # >> r.blocks.first.statements.map{|s| s.lines}
    # => [[">> t = 1"], [">> t + 2"]]
    # 
    # >> r.blocks.first.result.lines
    # => ["=> 3"]
    # 
    # >> r.blocks.last.statements.map{|s| s.lines}
    # => [[">> u = 1"]]
    # 
    # >> r.blocks.last.result
    # => nil
    #
    # doctest: Two doctest directives--each having its own statement--should be separated properly
    #          by organize_blocks.
    # >> r = RubyDocTest::Runner.new("doctest: one\n>> t = 1\ndoctest: two\n>> t + 2", "test.doctest")
    # >> r.run_file
    # >> r.blocks.map{|b| b.class}
    # => [RubyDocTest::SpecialDirective, RubyDocTest::CodeBlock,
    #     RubyDocTest::SpecialDirective, RubyDocTest::CodeBlock]
    #
    # >> r.blocks[0].value
    # => "one"
    #
    # >> r.blocks[1].statements.map{|s| s.lines}
    # => [[">> t = 1"]]
    #
    # >> r.blocks[2].value
    # => "two"
    #
    # >> r.blocks[3].statements.map{|s| s.lines}
    # => [[">> t + 2"]]
    def organize_blocks(groups = @groups)
      blocks = []
      current_statements = []
      groups.each do |g|
        case g
        when Statement
          current_statements << g
        when Result
          blocks << CodeBlock.new(current_statements, g)
          current_statements = []
        when SpecialDirective
          case g.name
          when "doctest"
            blocks << CodeBlock.new(current_statements) unless current_statements.empty?
            current_statements = []
          end
          blocks << g
        end
      end
      blocks << CodeBlock.new(current_statements) unless current_statements.empty?
      blocks
    end
    
    # === Tests
    # 
    # doctest: Tests should be organized into groups based on the 'doctest' SpecialDirective
    # >> r = RubyDocTest::Runner.new("doctest: one\n>> t = 1\ndoctest: two\n>> t + 2", "test.doctest")
    # >> r.run_file
    # >> r.tests.size
    # => 2
    # >> r.tests[0].code_blocks.map{|c| c.statements}.flatten.map{|s| s.lines}
    # => [[">> t = 1"]]
    # >> r.tests[1].code_blocks.map{|c| c.statements}.flatten.map{|s| s.lines}
    # => [[">> t + 2"]]
    # >> r.tests[0].description
    # => "one"
    # >> r.tests[1].description
    # => "two"
    #
    # doctest: Without a 'doctest' SpecialDirective, there is one Test called "Default Test".
    # >> r = RubyDocTest::Runner.new(">> t = 1\n>> t + 2\n=> 3\n>> u = 1", "test.doctest")
    # >> r.run_file
    # >> r.tests.size
    # => 1
    # 
    # >> r.tests.first.description
    # => "Default Test"
    # 
    # >> r.tests.first.code_blocks.size
    # => 2
    def organize_tests(blocks = @blocks)
      tests = []
      assigned_blocks = nil
      unassigned_blocks = []
      blocks.each do |g|
        case g
        when CodeBlock
          puts "a"
          p assigned_blocks
          puts "u"
          p unassigned_blocks
          (assigned_blocks || unassigned_blocks) << g
        when SpecialDirective
          case g.name
          when "doctest"
            assigned_blocks = []
            tests << Test.new(g.value, assigned_blocks)
          end
        end
      end
      tests << Test.new("Default Test", unassigned_blocks) unless unassigned_blocks.empty?
      tests
    end
  end
end
