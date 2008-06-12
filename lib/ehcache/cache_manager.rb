# TODO statuses
module Ehcache
  class CacheManager
    def initialize(options={})
      unless options[:security]
        import java.lang.System unless defined?(System)
        import java.rmi.RMISecurityManager unless defined?(RMISecurityManager)
        if System.getSecurityManager == nil
          RMISecurityManager.new.inspect
        end
      end
      @manager = Ehcache::Java::CacheManager.new(Ehcache::Config.default)
    end

    # return cache by name
    def cache(cache_name)
      Ehcache::Cache.new(@manager, cache_name)
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
