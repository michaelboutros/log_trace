require File.dirname(__FILE__) + '/../../../../../test/test_helper'

require 'log_trace'

class LogTraceController < ActionController::Base
  include LogTrace::Controller
  
  def rescue_action(error); raise error; end;
end

class LogTraceControllerTest < Test::Unit::TestCase
  def setup
    @controller = LogTraceController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_index
    get :index
    assert_response :success
  end
  
  def test_show_with_no_ip
    get :show
    
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert flash[:error_message] == 'Please provide an IP address.'
    
    follow_redirect
    assert_tag :p, :descendant => {:tag => 'span', :attributes => {:class => 'flash_error_message'}}
  end
  
  def test_show_with_invalid_ip
    get :show, {:id => '1111-1111-1111-1111'}
    
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert flash[:error_message] == "Please provide a valid IP address."
    
    follow_redirect
    assert_tag :p, :descendant => {:tag => 'span', :attributes => {:class => 'flash_error_message'}}
  end
  
  def test_show_with_valid_ip
    get :show, {:id => '0-0-0-0'}
    assert_response :success
  
    assert_not_nil assigns(:blocks)
    
    assert_tag :table, :children => {:only => {:tag => 'tbody', :attributes => {:id => /visit_\d+/}}, :count => 1}
    assert_tag :table, :children => {:only => {:tag => 'tbody', :attributes => {:id => /hits_\d+/}}, :count => 1}
  end
end