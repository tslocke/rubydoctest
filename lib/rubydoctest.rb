$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'irb'
require "runner"

module RubyDocTest
  
  class << self
    attr_accessor :trace, :ignore_interactive
    attr_writer :output_format
    
    def output_format
      if @output_format == :ansi or (@output_format.nil? and STDOUT.tty?)
        :ansi
      elsif @output_format == :html
        :html
      else
        :plain
      end
    end
    
    def indent(s, level=4)
      spaces = " " * level
      spaces + s.split("\n").join("\n#{spaces}")
    end
  end
  
end
