$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'irb'

module RubyDocTest
  
  class << self
    attr_accessor :trace
    
    def indent(s, level=4)
      spaces = " " * level
      spaces + s.split("\n").join("\n#{spaces}")
    end
  end
  
end

require "lines"
require "statement"
require "result"
require "special_directive"
require "test"
require "runner"