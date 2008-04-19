require File.dirname(__FILE__) + '/../../../../../test/test_helper'
require 'log_trace'

class LogTraceParserTest < Test::Unit::TestCase
  def setup
    @parser = LogTrace::Parser
  end
  
  def test_parse_with_default_environment_and_log_file
    parsed = @parser.parse_log
    generic_parse_tests(parsed)
  end
  
  def test_parse_with_other_environment
    parsed = @parser.parse_log('production')
    generic_parse_tests(parsed)
  end
  
  def test_parse_with_valid_other_log_file
    parsed = @parser.parse_log(nil, RAILS_ROOT + '/log/test.log')    
    generic_parse_tests(parsed)
  end
  
  def test_parse_with_invalid_other_log_file
    assert_raise RuntimeError do
      parsed = @parser.parse_log(nil, RAILS_ROOT + '/missing/file/')
    end
  end
  
  def test_parse_with_valid_environment_and_other_log_file
    assert_raise RuntimeError do
      parsed = @parser.parse_log('development', RAILS_ROOT + '/log/test.log') 
    end
  end
  
  def test_invalid_return_by_parse_method
    assert_raise NoMethodError do
      @parser.parse_and_return_by(:foobar)
    end
  end
  
  def test_valid_return_by_parse_method
    parsed = @parser.parse_log_and_return_by_ip
    
    assert parsed.is_a?(Hash)
    assert parsed.keys.include?('0.0.0.0')
  end

  private
    def generic_parse_tests(parsed)      
      assert_not_nil parsed
      assert parsed.is_a?(Array)
      assert parsed.each {|h| h.keys.sort {|a, b| a.to_s <=> b.to_s} == [:action, :controller, :datetime, :ip, :method, :parameters]}
      
      assert parsed.each {|h| h[:datetime].is_a?(Time)}
    end
end