$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'lines'

module RubyDocTest
  class Result < Lines
    def compute_range(doc_lines = @doc_lines, start_index = @line_index)
      puts "doc_lines: #{@doc_lines.size}, start_index: #{start_index.inspect}"
      super
    end
  end
end