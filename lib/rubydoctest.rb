$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'irb'

class RubyDocTest
  
  class << self
    attr_accessor :trace
  end

  PROMPT_RX = /^[>?]>( |\s*$)/
  
  RESULT_RX = /^=> /
  
  CODE_LINE_RX = /^(    |\t)/
  
  def initialize(src, file_name)
    @passed = 0
    @block_count = 0
    @failures = []
    @src = src
    @remaining_src_lines = src.split("\n")
    @line_num = 0
    @file_name = file_name
    
    # next_line # get first line
  end
  
  def run(options = {})
    inline_errors = options[:inline_errors]
    run_file
    if inline_errors
      puts %Q{<div id="rubydoctest-summary" class="#{failures.size > 0 ? 'fail' : 'pass'}">}
      print_report
      puts "</div>\n#{src}"
    else
      print_report
    end
  end
  
  attr_accessor :passed, :failures, :current_line, :src, :remaining_src_lines, :line_num, :block_count
  
  def environment
    TOPLEVEL_BINDING
  end
  
  def next_line
    @line_num += 1
    @current_line = remaining_src_lines.shift
  end
  
  def next_line?
    remaining_src_lines.any?
  end
  
  def strip_prompt(s)
    s.sub(PROMPT_RX, "")
  end

  def result_start?(s=current_line)
    s =~ RESULT_RX
  end
  
  def string_result_start?(s=current_line)
    s =~ /^=>""/
  end
  
  def statement_start?(s=current_line)
    s =~ PROMPT_RX
  end
  
  def strip_result_marker(s=current_line)
    s.sub(RESULT_RX, "")
  end
  
  def normalize_result(s)
    s.gsub(/:0x[a-f0-9]{8}>/, ':0xXXXXXXXX>').strip
  end
  
  def code_line?(s=current_line)
    s =~ CODE_LINE_RX
  end
  
  def code_block_start?(s=current_line)
    l = unindent_code_line
    code_line? && (statement_start?(l) || irb_interrupt?(l))
  end
  
  def blank_line?(s=current_line)
    s =~ /^\s*$/
  end
  
  def irb_interrupt?(line)
    line =~ /!!!/
  end
  
  def run_file
    # run_code_block if code_block_start?
    while next_line
      run_code_block if code_block_start?
    end
    failures.length == 0
  end
  
  def unindent_code_line(s=current_line)
    s.sub(CODE_LINE_RX, "")
  end
  
  
  def get_code_lines
    lines = []
    while blank_line? || code_line?
      lines << [unindent_code_line, line_num]
      next_line
    end
    lines.pop while blank_line?(lines.last)
    lines
  end
  
  
  def run_code_block
    self.block_count += 1
    
    lines = get_code_lines
    
    reading = :statement

    result = nil
    statement = ""
    statement_line = lines.first.last
    lines.each do |line, line_num|
      
      if irb_interrupt?(line)
        evaluate(statement, statement_line) unless statement == ""
        
        puts statement unless statement.blank?
        puts "=> #{result}" unless result.blank?
        puts
        
        start_irb
        line = nil
        
      elsif string_result_start?(line)
        reading = :string_result
        line = nil
        result = ""
        
      elsif result_start?(line)
        reading = :ruby_result
        line = strip_result_marker(line)
        result = ""

      elsif statement_start?(line)
        if result
          # start of a new statement
          if reading == :string_result
            # end of a string result statement
            result.chomp!
            run_statement(statement, result, statement_line, true)
          else
            run_statement(statement, result, statement_line)
          end
          statement_line = line_num
          statement = ""
          result = nil
        end
        reading = :statement
      end
      
      if reading == :statement
        # The statement has a prompt on every line
        if line
          line = strip_prompt(line)
          statement << line + "\n" 
        end
      else
        # There's only one result marker - stripped above
        result << line + "\n" if line
      end
      
    end
    
    if result.nil?
      # The block ends with a statement - just evaluate it
      evaluate(statement, statement_line)
    else
      run_statement(statement, result, statement_line)
    end
  end
  
  
  def start_irb
    IRB.init_config(nil)
    IRB.conf[:PROMPT_MODE] = :SIMPLE
    irb = IRB::Irb.new(IRB::WorkSpace.new(environment))
    IRB.conf[:MAIN_CONTEXT] = irb.context
    irb.eval_input
  end
  
  
  def run_statement(statement, expected_result, statement_line, string_comparison=false)
    actual_result = evaluate(statement, statement_line)
    
    if result_matches?(expected_result, actual_result, string_comparison)
      self.passed += 1
    else
      actual_result = actual_result.inspect unless string_comparison
      failures << [statement, actual_result, expected_result, statement_line]
    end
  end
  
  
  def result_matches?(expected_result, actual_result, string_comparison)
    if string_comparison
      actual_result == expected_result
    else
      actual_result = actual_result.inspect
      normalize_result(expected_result) == normalize_result(actual_result) or
          # If the expected result looks like a literal, see if they eval to equal objects - this will often fail
          if expected_result =~ /^[:\[{A-Z'"%\/]/
            begin
              eval(expected_result) == eval(actual_result)
            rescue Exception
              false
            end
          end
    end
  end
  
  
  def evaluate(statement, line_num)
    statement.gsub!("__FILE__", @file_name.inspect)
    eval(statement, environment, __FILE__, __LINE__)
  rescue SyntaxError => e
    puts "Syntax error in statement on line #{line_num}:"
    puts indent(statement)
    puts e.to_s
    puts
    exit 1
  rescue Exception => e
    puts "Exception in statement on line #{line_num}:"
    puts indent(statement)
    puts e.backtrace
    
    if RubyDocTest.trace
      raise
    else
      puts e.to_s
      puts
      exit 1      
    end
  end
  
  
  def number_run
    passed + failures.length
  end
  
  def indent(s, level=4)
    spaces = " " * level
    spaces + s.split("\n").join("\n#{spaces}")
  end
  
  def print_report
    statements_per_block = number_run.to_f / block_count
    puts("%d blocks, %d tests (avg. %.1f/block), %d failures\n\n" %
         [block_count, number_run, statements_per_block, failures.length])
    
    failures.each do |statement, actual, expected, lnum|
      puts "Failure line #{lnum}"
      puts "  Statement:", indent(statement)
      puts "  Expected:",  indent(expected)
      puts "  Got:\n",     indent(actual)
      puts
    end
  end

end
