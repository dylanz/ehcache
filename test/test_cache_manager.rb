require File.dirname(__FILE__) + '/test_helper.rb'

class TestCacheManager < Test::Unit::TestCase
  def setup
    @cache_manager = Ehcache::CacheManager.new
  end

  def teardown
    @cache_manager.shutdown if @cache_manager
  end

  must 'be the real Ehcache Java CacheManager' do
    assert_kind_of(Java::NetSfEhcache::CacheManager, @cache_manager)
  end

  must 'use the ehcache.xml file in the test directory' do
    @cache_manager.cache_names.each do |name|
      puts "Cache: #{name}"
    end
  end

  must 'implement each and include Enumerable' do
    assert_kind_of(Enumerable, @cache_manager)
    assert_respond_to(@cache_manager, :each)
    assert @cache_manager.all? {|cache| cache.is_a?(Java::NetSfEhcache::Ehcache)}
  end
end
