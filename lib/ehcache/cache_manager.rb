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

__END__
module Ehcache
  class CacheManager
    def initialize(options={})
      # TODO document this
      unless options[:security]
        import java.lang.System unless defined?(System)
        import java.rmi.RMISecurityManager unless defined?(RMISecurityManager)
        RMISecurityManager.new if System.getSecurityManager == nil
      end
      @manager = Ehcache::Java::CacheManager.new(Ehcache::Config.generate(options))
    end

    # return cache by name
    def cache(cache_name=nil)
      Ehcache::Cache.new(@manager, cache_name || Ehcache::Cache::PRIMARY)
    end

    # return all cache names
    def caches
      @manager.get_cache_names
    end

    # adds cache based on default configuration
    def add_cache(cache_name)
      @manager.add_cache(cache_name)
    end

    # remove cache
    def remove(cache_name)
      @manager.remove_cache(cache_name)
    end

    # remove all caches
    def remove_all
      @manager.removal_all
    end

    # empty all caches
    def flush_all
      @manager.clear_all
    end

    def enable_shutdown_hook
      @manager.add_shutdown_hook_if_required
    end

    def disable_shutdown_hook
      @manager.disable_shutdown_hook
    end

    def shutdown
      @manager.shutdown
    end

    def status
      @manager.get_status.to_s
    end

    # true if cache by given name is being managed, false otherwise
    def include?(cache_name)
      @manager.cache_exists(cache_name)
    end
    alias_method :exists?, :include?
  end
end
