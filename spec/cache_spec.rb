require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Cache do
  before(:each) do
    @manager = Ehcache::CacheManager.new
    @cache   = @manager.cache
  end

  after(:each) do
    @manager.shutdown
  end

  it "should return an element value from get when given a valid key" do
    @cache.put("lol", "123456")
    @cache.get("lol").should == "123456"
  end

  it "should return an element from a call to element when given a valid key" do
    @cache.put("lol", "123456")
    @cache.element("lol").class.should == Ehcache::Element
  end

  it "should return the number of elements in the cache" do
    @cache.size.should == 0
    @cache.put("lol", "123456")
    @cache.size.should == 1
  end

  it "should return the number of elements in the memory store"
  it "should return the number of elements in the disk store"
end
