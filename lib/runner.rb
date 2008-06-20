$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubydoctest'
require 'statement'
require 'result'
require 'special_directive'
require 'code_block'
require 'test'

module RubyDocTest
  class Runner
    attr_reader :groups, :blocks, :tests
    
    @@color = {
      :html => {
        :red    => %{<font color="red">%s</font>},
        :yellow => %{<font color="#C0C000">%s</font>},
        :green  => %{<font color="green">%s</font>}
      },
      :ansi => {
        :red    => %{\e[31m%s\e[0m},
        :yellow => %{\e[33m%s\e[0m},
        :green  => %{\e[32m%s\e[0m}
      },
      :plain => {
        :red    => "%s",
        :yellow => "%s",
        :green  => "%s"
      }
    }
    
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
    # => ["a", "b"]
    def initialize(src, file_name = "test.doctest", initial_mode = nil)
      @src, @file_name = src, file_name
      @mode = initial_mode || (File.extname(file_name) == ".rb" ? :ruby : :doctest)
      
      @src_lines = src.split("\n")
      @groups, @blocks = [], []
    end
    
    def prepare_tests
      eval(@src, TOPLEVEL_BINDING, @file_name) if @mode == :ruby
      @groups = read_groups
      @blocks = organize_blocks
      @tests = organize_tests
    end
    
    # === Tests
    # doctest: Run through a simple inline doctest (rb) file and see if it passes
    # >> file = File.join(File.dirname(__FILE__), "..", "test", "inline.rb")
    # >> r = RubyDocTest::Runner.new(IO.read(file), "inline.rb")
    # >> r.pass?
    # => true
    def pass?
      prepare_tests
      @tests.all?{ |t| t.pass? }
    end
    
    # === Description
    # Starts an IRB prompt when the "!!!" SpecialDirective is given.
    def start_irb
      IRB.init_config(nil)
      IRB.conf[:PROMPT_MODE] = :SIMPLE
      irb = IRB::Irb.new(IRB::WorkSpace.new(TOPLEVEL_BINDING))
      IRB.conf[:MAIN_CONTEXT] = irb.context
      catch(:IRB_EXIT) do
        irb.eval_input
      end
    end
    
    def format_color(text, color)
      @@color[RubyDocTest.output_format][color] % text.to_s
    end
    
    def run
      prepare_tests
      newline = "\n       "
      everything_passed = true
      puts "=== Testing '#{@file_name}'..."
      ok, fail, err = 0, 0, 0
      @tests.each do |t|
        if SpecialDirective === t
          start_irb
        else
          begin
            if t.pass?
              ok += 1
              status = ["OK".center(4), :green]
              detail = nil
            else
              fail += 1
              everything_passed = false
              status = ["FAIL".center(4), :red]
              detail = format_color(
                "Got: #{t.actual_result}#{newline}Expected: #{t.expected_result}" + newline +
                  "  from #{@file_name}:#{t.first_failed.result.line_number}",
                :red)
              
            end
          rescue EvaluationError => e
            err += 1
            status = ["ERR".center(4), :yellow]
            exception_text = e.original_exception.to_s.split("\n").join(newline)
            if RubyDocTest.output_format == :html
              exception_text = exception_text.gsub("<", "&lt;").gsub(">", "&gt;")
            end
            detail = format_color(
              "#{e.original_exception.class.to_s}: #{exception_text}" + newline +
                "  from #{@file_name}:#{e.statement.line_number}" + newline +
                e.statement.source_code,
              :yellow)
          end
          puts \
            "#{format_color(*status)} | " +
            "#{t.description.split("\n").join(newline)}" +
            (detail ? newline + detail : "")
        end
      end
      puts \
        "#{@blocks.select{ |b| b.is_a? CodeBlock }.size} comparisons, " +
        "#{@tests.size} doctests, " +
        "#{fail} failures, " +
        "#{err} errors"
      everything_passed
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
            if g = match_group("\\s*#\\s*", src_lines, index)
              groups << g
            end
          
          end
        when :doctest
          if g = match_group("\\s*", src_lines, index)
            groups << g
          end
          
        when :doctest_with_end
          break if line =~ /^=end/
          if g = match_group("\\s*", src_lines, index)
            groups << g
          end
          
        end
      end
      groups
    end
    
    def match_group(prefix, src_lines, index)
      case src_lines[index]
      
      # An irb '>>' marker after a '#' indicates an embedded doctest
      when /^(#{prefix})>>(\s|\s*$)/
        Statement.new(src_lines, index, @file_name)
      
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
    # >> r.prepare_tests
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
    # >> r.prepare_tests
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
          when "doctest:"
            blocks << CodeBlock.new(current_statements) unless current_statements.empty?
            current_statements = []
          when "!!!"
            # ignore
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
    # >> r.prepare_tests
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
    # >> r.prepare_tests
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
          (assigned_blocks || unassigned_blocks) << g
        when SpecialDirective
          case g.name
          when "doctest:"
            assigned_blocks = []
            tests << Test.new(g.value, assigned_blocks)
          when "!!!"
            tests << g
          end
        end
      end
      tests << Test.new("Default Test", unassigned_blocks) unless unassigned_blocks.empty?
      tests
    end
  end
end
