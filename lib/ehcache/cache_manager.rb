# TODO statuses
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
