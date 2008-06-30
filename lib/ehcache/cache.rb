module Ehcache
  class Cache
    PRIMARY = "primary"

    # pull cache from given manager by name
    def initialize(manager, cache_name)
      @cache = manager.get_cache(cache_name)
    end

    # put a new element into the cache
    def put(key, value)
      @cache.put(Ehcache::Java::Element.new(key, value))
    end
    alias_method :set, :put

    # get an element value from cache by key
    def get(key)
      element = @cache.get(key)
      element ? element.get_value : nil
    end

    # get an element from cache by key
    def element(key)
      element = @cache.get(key)
      return nil unless element
      Ehcache::Element.new(element.get_key, element.get_value)
    end

    # number of elements in the cache
    def size
      @cache.get_size
    end

    # number of elements in the memory store
    def memory_size
      @cache.get_memory_store_size
    end

    # number of elements in the cache store
    def disk_size
      @cache.get_disk_store_size
    end

    def max_elements
      @cache.get_max_elements_in_memory
    end

    def eternal?
      @cache.is_eternal
    end
    
    def ttl
      @cache.get_time_to_live_seconds
    end

    def tti
      @cache.get_time_to_idle_seconds
    end
  end
end
