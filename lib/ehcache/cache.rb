module Ehcache
  class Cache
    PRIMARY = "primary"

    # pull cache from given manager by name
    def initialize(manager, cache_name)
      @proxy = manager.get_cache(cache_name)
    end

    # put a new element into the cache
    def put(key, value, options = {})
      if key.nil? || key.empty?
        raise EhcacheError, "Element cannot be blank"
      end
      element = Ehcache::Element.new(key, value, options)
      @proxy.put(element.proxy)
    rescue NativeException => e
      raise EhcacheError, e.cause
    end
    alias_method :set, :put

    # another alias for put
    def []=(key, value)
      put(key, value)
    end

    # get an element value from cache by key
    def get(key)
      element = @proxy.get(key)
      element ? element.get_value : nil
    rescue NativeException => e
      raise EhcacheError, e.cause
    end
    alias_method :[], :get

    # get an element from cache by key
    def element(key)
      element = @proxy.get(key)
      return nil unless element
      Ehcache::Element.new(element.get_key, element.get_value,
        {:ttl => element.get_time_to_live })
    rescue NativeException => e
      raise EhcacheError, e.cause
    end

    # remove an element from the cache by key
    def remove(key)
      @proxy.remove(key)
    rescue NativeException => e
      raise EhcacheError, e.cause
    end
    alias_method :delete, :remove

    # remove all elements from the cache
    def remove_all
      @proxy.remove_all
    rescue NativeException => e
      raise EhcacheError, e.cause
    end
    alias_method :clear, :remove_all

    def keys
      @proxy.get_keys
    end

    def exist?(key)
      @proxy.is_key_in_cache(key)
    end

    # returns the current status of the cache
    def status
      @proxy.get_status
    end

    def alive?
      @proxy.get_status == Status::ALIVE
    end

    def shutdown?
      @proxy.get_status == Status::SHUTDOWN
    end

    def uninitialized?
      @proxy.get_status == Status::UNINITIALISED
    end

    # number of elements in the cache
    def size
      @proxy.get_size
    end

    # number of elements in the memory store
    def memory_size
      @proxy.get_memory_store_size
    end

    # number of elements in the cache store
    def disk_size
      @proxy.get_disk_store_size
    end

    # TODO: implement statistics !
    # return statistics about the cache
    def statistics
      @proxy.get_statistics
    rescue NativeException => e
      raise EhcacheError, e.cause
    end

    def max_elements
      @proxy.get_max_elements_in_memory
    end

    def eternal?
      @proxy.is_eternal
    end
    
    def ttl
      @proxy.get_time_to_live_seconds
    end

    def tti
      @proxy.get_time_to_idle_seconds
    end
  end
end
