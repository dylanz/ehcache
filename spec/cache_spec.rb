require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Cache do
  before(:each) do
    @manager = Ehcache::CacheManager.new
    @cache   = @manager.cache
  end

  after(:each) do
    @manager.shutdown
  end

  it "should have an alive status on creation" do
    @cache.status.should == Ehcache::Status::ALIVE
  end

  it "should have a shutdown status when its manager shutsdown" do
    @manager.shutdown
    @cache.status.should == Ehcache::Status::SHUTDOWN
  end

  it "should return an element value from get when given a valid key" do
    @cache.put("lol", "123456")
    @cache.get("lol").should == "123456"
  end

  it "should return true when removing an element from the cache given a valid key" do
    @cache.put("lol", "123456")
    @cache.remove("lol").should == true
  end

  it "should return false when removing an element from the cache given a valid key" do
    @cache.put("lol", "123456")
    @cache.remove("rofl").should == false
  end

  it "should remove all elements from the cache on a call to remove_all" do
    @cache.put("lol", "123456")
    @cache.put("rofl", "123456")
    @cache.remove_all
    @cache.size.should == 0
  end

  it "should return true when exist? is called when a valid key is in the cache" do
    @cache.put("lol", "123456")
    @cache.exist?("lol").should == true
  end

  it "should return false when exist? is called when a valid key is in the cache" do
    @cache.put("lol", "123456")
    @cache.exist?("rofl").should == false
  end

  it "should raise an EhcacheArgumentException when given an empty key" do
    lambda { @cache.put("", "123456") }.should raise_error(EhcacheError)
  end

  it "should raise an EhcacheArgumentException when given nil key" do
    lambda { @cache.put(nil, "123456") }.should raise_error(EhcacheError)
  end

  it "should allow adding an element to the cache with a time to live" do
    @cache.put("lol", "123456", { :ttl => 60 })
    @cache.element("lol").ttl.should == 60
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

  it "should return all the keys in the cache" do
    @cache.put("lol", "123456")
    @cache.put("rofl", "123456")
    @cache.keys.size.should == 2
  end

  it "should return the number of elements in the memory store"
  it "should return the number of elements in the disk store"
end
