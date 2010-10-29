# Enhance net.sf.ehcache.CacheManager with a more Rubyesque API.
class Java::NetSfEhcache::CacheManager
  include Enumerable

  class << self
    alias_method :ehcache_create, :create

    # Enhanced create that provides for some extra configuration options.
    # Specifically, String arguments may be used where native Ehcache expects
    # java.io.File objects, and if the String refers to a YAML file it will be
    # used as the Configuration source.
    def create(*args)
      process_init_args(*args) do |*args|
        ehcache_create(*args)
      end
    end
  end

  # Enhanced constructor that provides for some extra configuration options.
  # Specifically, String arguments may be used where native Ehcache expects
  # java.io.File objects, and if the String refers to a YAML file it will be
  # used as the Configuration source.
  def initialize(*args)
    process_init_args(*args) do |*args|
      super(*args)
    end
  end

  # Iterate through each cache managed by this CacheManager.
  def each
    for name in self.cache_names
      yield self.get_ehcache(name)
    end
  end

  alias [] get_ehcache

  def cache(cache_name = '__default_jruby_cache')
    self.add_cache_if_absent(cache_name)
    self.get_ehcache(cache_name)
  end

  # true if cache by given name is being managed, false otherwise
  def include?(cache_name)
    self.cache_exists(cache_name)
  end
  alias_method :exists?, :include?
end

# Helper method for processing initialization arguments passed to
# CacheManager.create and CacheManager#initialize.
def process_init_args(*args)
  if args.empty?
    # First, look relative to the file that is creating the CacheManager.
    # The expression caller[2] finds the entry in the call stack where
    # CacheManager.new or CacheManager.create was called.
    creator = /^(.+?):\d/.match(caller[2])[1]
    if ehcache_config = Java::NetSfEhcacheConfig::Configuration.find(File.dirname(creator))
      yield(ehcache_config)
    else
      yield
    end
  elsif args.size == 1 && args.first.is_a?(String)
    yield(Ehcache::Config::Configuration.create(args.first))
  else
    yield(*args)
  end
end
