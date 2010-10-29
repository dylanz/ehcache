require File.dirname(__FILE__) + '/test_helper.rb'

class TestEhcache < Test::Unit::TestCase

  def setup
    @manager = Ehcache::CacheManager.new
    @cache = @manager.cache
  end

  def teardown
    @manager.shutdown
  end
  
  def test_demo_usage
    @cache.put("answer", "42", {:ttl => 120})
    answer = @cache.get("answer")
    assert_equal("42", answer.value)
    assert_equal(120, answer.ttl)
    question = @cache["question"] || 'unknown'
    assert_equal('unknown', question)
  end
end
