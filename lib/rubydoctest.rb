$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'irb'
require "runner"

module RubyDocTest
  
  class << self
    attr_accessor :trace, :ansi
    
    def ansi
      @ansi == nil ? STDOUT.tty? : @ansi
    end
    
    def indent(s, level=4)
      spaces = " " * level
      spaces + s.split("\n").join("\n#{spaces}")
    end
  end
  
end
