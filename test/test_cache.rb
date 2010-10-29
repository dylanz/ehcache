require File.dirname(__FILE__) + '/test_helper.rb'

class TestCache < Test::Unit::TestCase

  def setup
    @manager = Ehcache::CacheManager.new
    @cache = @manager.cache
  end

  def teardown
    @manager.shutdown if @manager
  end

  must 'correctly implement compare and swap' do
    @cache.put('number', 42, {:ttl => 120})
    assert_equal(42, @cache['number'])
    @cache.compare_and_swap('number') {|n| n - 31}
    assert_equal(11, @cache['number'])
  end

  must 'have aliases for isKeyInCache called include and member' do
    @cache.put('something', 'no matter')
    for key in %w[something nothing]
      assert_equal(@cache.isKeyInCache(key), @cache.include?(key))
      assert_equal(@cache.isKeyInCache(key), @cache.member?(key))
    end
  end

  must 'implement each and include Enumerable' do
    assert_kind_of(Enumerable, @cache)
    assert_respond_to(@cache, :each)
    @cache.put('1', 1)
    @cache.put('2', 2)
    assert @cache.all? {|e| e.is_a?(Java::NetSfEhcache::Element)}
  end
end