$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'lines'

module RubyDocTest
  class Result < Lines
    
    def normalize_result(s)
      s.gsub(/:0x[a-f0-9]{8}>/, ':0xXXXXXXXX>').strip
    end
    
    def expected_result
      @expected_result ||=
        begin
          lines.first =~ /^#{Regexp.escape(indentation)}=>\s(.*)$/
          ([$1] + (lines[1..-1] || [])).join("\n")
        end
    end
    
    # === Tests
    # doctest: Strings should match
    # >> r = RubyDocTest::Result.new(["=> 'hi'"])
    # >> r.matches? 'hi'
    # => true
    #
    # >> r = RubyDocTest::Result.new(["=> \"hi\""])
    # >> r.matches? "hi"
    # => true
    #
    # doctest: Regexps should match
    # >> r = RubyDocTest::Result.new(["=> /^reg.../"])
    # >> r.matches? /^reg.../
    # => true
    #
    # >> r = RubyDocTest::Result.new(["=> /^reg.../"])
    # >> r.matches? /^regexp/
    # => false
    #
    # doctest: Arrays should match
    # >> r = RubyDocTest::Result.new(["=> [1, 2, 3]"])
    # >> r.matches? [1, 2, 3]
    # => true
    #
    # doctest: Arrays of arrays should match
    # >> r = RubyDocTest::Result.new(["=> [[1, 2], [3, 4]]"])
    # >> r.matches? [[1, 2], [3, 4]]
    # => true
    #
    # doctest: Hashes should match
    # >> r = RubyDocTest::Result.new(["=> {:one => 1, :two => 2}"])
    # >> r.matches?({:two => 2, :one => 1})
    # => true
    def matches?(actual_result, string_comparison = false)
      if string_comparison
        actual_result == expected_result
      else
        actual_result = actual_result.inspect
        normalize_result(expected_result) == normalize_result(actual_result) or
            # If the expected result looks like a literal, see if they eval to
            # equal objects. This will often fail.
            if expected_result =~ /^[:\[{A-Z'"%\/]/
              begin
                eval(expected_result) == eval(actual_result)
              rescue Exception
                false
              end
            end
      end
    end
    
    def start_irb
      IRB.init_config(nil)
      IRB.conf[:PROMPT_MODE] = :SIMPLE
      irb = IRB::Irb.new(IRB::WorkSpace.new(environment))
      IRB.conf[:MAIN_CONTEXT] = irb.context
      irb.eval_input
    end
  end
end