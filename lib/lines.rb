module RubyDocTest
  # === Description
  # Keeps track of which lines within a document belong to a group.  Line groups are
  # determined by their indentation level, as in the Python programming language.
  #
  # === Example
  #  This line and the next one
  #    are part of the same group
  #
  #  But this line is separate from
  #  this line.
  #
  # === Note
  # This class also considers one '#' character (comment) as an indentation character,
  # i.e. similar to how whitespace is treated.
  class Lines
    def initialize(doc_lines, line_index = 0)
      @doc_lines, @line_index = doc_lines, line_index
    end
    
    
    def line_number
      @line_index + 1
    end
    
    # === Tests
    # doctest: Return an array of 1 line if there is only one line
    # >> l = RubyDocTest::Lines.new(["line 1"])
    # >> l.lines
    # => ["line 1"]
    #
    # doctest: Remove indentation from lines 2 to the end of this Lines group.
    # >> l = RubyDocTest::Lines.new(["line 1", "  line 2", "  line 3", "    line 4"])
    # >> l.lines
    # => ["line 1", "line 2", "line 3", "  line 4"]
    def lines
      r = range
      size = r.last - r.first + 1
      if size > 1
        # Remove indentation from all lines after the first,
        # as measured from the 2nd line's indentation level
        idt2 = indentation(@doc_lines, @line_index + 1)
        [@doc_lines[range.first]] +
        @doc_lines[(range.first + 1)..(range.last)].
          map{ |l| $1 if l =~ /^#{Regexp.escape(idt2)}(.*)/ }
      else
        @doc_lines[range]
      end
    end
    
    
    # === Description
    # Calculate the range of python-like indentation within this Lines group
    #
    # === Tests
    # >> l = RubyDocTest::Lines.new([])
    #
    # doctest: Return a range of one line when there is only one line to begin with
    # >> l.range %w(a), 0
    # => 0..0
    #
    # doctest: Return a range of one line when there are two lines, side by side
    # >> l.range %w(a b), 0
    # => 0..0
    # >> l.range %w(a b), 1
    # => 1..1
    #
    # doctest: Return a range of two lines when there are two lines, the second blank
    # >> l.range ["a", ""], 0
    # => 0..1
    #
    # doctest: Return a range of two lines when the second is indented
    # >> l.range ["a", " b"], 0
    # => 0..1
    def range(doc_lines = @doc_lines, start_index = @line_index)
      end_index = start_index
      idt = indentation(doc_lines, start_index)
      # Find next lines that are blank, or have indentation more than the first line
      remaining_lines(doc_lines, start_index + 1).each do |current_line|
        if current_line =~ /^(#{Regexp.escape(idt)}\s+|\s*$)/
          end_index += 1
        else
          break
        end
      end
      # Compute the range from what we found
      start_index..end_index
    end
    
    def inspect
      "#<#{self.class} lines=#{lines.inspect}>"
    end
    
    protected
    
    # === Tests
    # >> l = RubyDocTest::Lines.new([])
    #
    # doctest: Get a whitespace indent from a line with whitespace
    # >> l.send :indentation, [" a"], 0
    # => " "
    #
    # doctest: Get a whitespace and '#' indent from a comment line
    # >> l.send :indentation, [" # a"], 0
    # => " # "
    def indentation(doc_lines = @doc_lines, line_index = @line_index)
      if doc_lines[line_index]
        doc_lines[line_index][/^(\s*#\s*|\s*)/]
      else
        ""
      end
    end
    
    
    # === Description
    # Get lines from +start_index+ up to the end of the document.
    #
    # === Tests
    # >> l = RubyDocTest::Lines.new([])
    # 
    # doctest: Return an empty array if start_index is out of bounds
    # >> l.send :remaining_lines, [], 1
    # => []
    # >> l.send :remaining_lines, [], -1
    # => []
    #
    # doctest: Return the specified line at start_index, up to and including the
    #          last line of +doc_lines+.
    # >> l.send :remaining_lines, %w(a b c), 1
    # => %w(b c)
    # >> l.send :remaining_lines, %w(a b c), 2
    # => %w(c)
    #
    def remaining_lines(doc_lines = @doc_lines, start_index = @line_index)
      return [] if start_index < 0 or start_index >= doc_lines.size
      doc_lines[start_index..-1]
    end
  end
end