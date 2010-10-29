require File.dirname(__FILE__) + '/test_helper.rb'

class TestElement < Test::Unit::TestCase
  ALIASES = {
    :tti => :time_to_idle,
    :ttl => :time_to_live
  }

  ALIASES.each do |short, long|
    must "have reader alias named #{short} referring to #{long}" do
      element = Ehcache::Element.new('', '')
      assert_respond_to(element, long)
      assert_respond_to(element, short)
      assert_equal(element.send(long), element.send(long))
    end

    must "have writer alias named #{short} referring to #{long}" do
      element = Ehcache::Element.new('', '')
      long_writer = "#{long}=".to_sym
      short_writer = "#{short}=".to_sym
      assert_respond_to(element, long_writer)
      assert_respond_to(element, short_writer)
      
      element.send(long_writer, 1)
      assert_equal(1, element.send(long))
      assert_equal(1, element.send(short))
      element.send(short_writer, 2)
      assert_equal(2, element.send(long))
      assert_equal(2, element.send(short))
    end
  end

  must 'process ttl option on create' do
    element = Ehcache::Element.create('k', 'v', :ttl => 42)
    assert_equal(element.ttl, 42)
  end
end
