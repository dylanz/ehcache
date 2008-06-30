require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CacheManager do
  before(:each) do
    @manager = Ehcache::CacheManager.new
  end

  after(:each) do
    @manager.shutdown
  end
  it "should return false if include? is called with a non-existant cache name" do
    @manager.include?("zomg").should == false
  end

  it "should return false if exists? is called with a non-existant cache name" do
    @manager.exists?("zomg").should == false
  end

  it "should return true if include? is called with an existant cache name" do
    @manager.include?(Ehcache::Cache::PRIMARY).should == true
  end

  it "should return true if exists? is called with an existant cache name" do
    @manager.exists?(Ehcache::Cache::PRIMARY).should == true
  end

  it "should return all the cache names when caches is called" do
    @manager.caches.length.should == 1
  end

  it "should remove the cache when remove is called with a cache name" do
    @manager.remove(Ehcache::Cache::PRIMARY)
    @manager.caches.length.should == 0
  end

  it "should remove all the caches when remove_all is called" do
    @manager.add_cache("mynewcache")
    @manager.caches.length.should == 2
    @manager.remove_all
    @manager.caches.length.should == 0
  end

  it "should add a cache when cache is called with a cache name" do
    @manager.add_cache("mynewcache")
    @manager.caches.length.should == 2
  end

  it "should add a cache when cache is called with a cache name" do
    cache = @manager.cache(Ehcache::Cache::PRIMARY)
    cache.put("key", "value")
    cache.get("key").should == "value"
    @manager.flush_all
    cache.get("key").should == nil
  end
end

describe CacheManager, "customized" do
  after(:each) do
    @manager.shutdown
  end

  it "should create a primary cache with values based on default cache" do
    @manager = Ehcache::CacheManager.new
    @manager.cache.max_elements.should == 10000
  end

  it "should create a cache with cache named steve" do
    @manager = Ehcache::CacheManager.new({"cache" => {"name" => "steve"}})
    @manager.include?("steve").should == true
  end

  it "should create a custom default and primary cache" do
    @manager = Ehcache::CacheManager.new({
      "default" => {"max_elements_in_memory" => 200000},
      "cache"   => {"name" => "cache", "time_to_live_seconds" => 180, "eternal" => true}
    })
    @manager.cache("cache").max_elements.should == 200000
    @manager.cache("cache").ttl.should == 180
    @manager.cache("cache").eternal?.should == true
  end
end
