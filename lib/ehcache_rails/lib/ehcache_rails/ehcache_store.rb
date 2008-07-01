require 'ehcache'

module ActiveSupport
  module Cache
    class EhcacheStore < Store
      module Response
        STORED      = "STORED\r\n"
        NOT_STORED  = "NOT_STORED\r\n"
        EXISTS      = "EXISTS\r\n"
        NOT_FOUND   = "NOT_FOUND\r\n"
        DELETED     = "DELETED\r\n"
      end

      #attr_reader :addresses

      def initialize(*addresses)
        puts "INITIALIZING EHCACHE STORE"
        #addresses = addresses.flatten
        #options = addresses.extract_options!
        #addresses = ["localhost"] if addresses.empty?
        #@addresses = addresses
        #@data = MemCache.new(addresses, options)
        manager = Ehcache::CacheManager.new
        @cache = manager.cache('cache')
      end

      def read(key, options = nil)
        super
        @data.get(key, raw?(options))
      rescue Exception => e
        logger.error("MemCacheError (#{e}): #{e.message}")
        nil
      end

      # Set key = value. Pass :unless_exist => true if you don't 
      # want to update the cache if the key is already set. 
      def write(key, value, options = nil)
        super
        method = options && options[:unless_exist] ? :add : :set
        response = @data.send(method, key, value, expires_in(options), raw?(options))
        response == Response::STORED
      rescue Exception => e
        logger.error("MemCacheError (#{e}): #{e.message}")
        false
      end

      def delete(key, options = nil)
        super
        response = @data.delete(key, expires_in(options))
        response == Response::DELETED
      rescue Exception => e
        logger.error("MemCacheError (#{e}): #{e.message}")
        false
      end

      def exist?(key, options = nil)
        # Doesn't call super, cause exist? in memcache is in fact a read
        # But who cares? Reading is very fast anyway
        !read(key, options).nil?
      end

      def increment(key, amount = 1)       
        log("incrementing", key, amount)
        
        response = @data.incr(key, amount)  
        response == Response::NOT_FOUND ? nil : response
      rescue Exception 
        nil
      end

      def decrement(key, amount = 1)
        log("decrement", key, amount)
        
        response = data.decr(key, amount) 
        response == Response::NOT_FOUND ? nil : response
      rescue Exception 
        nil
      end        
      
      def delete_matched(matcher, options = nil)
        super
        raise "Not supported by Memcache"
      end        
      
      def clear
        @data.flush_all
      end        
      
      def stats
        @data.stats
      end

      private
        def expires_in(options)
          (options && options[:expires_in]) || 0
        end

        def raw?(options)
          options && options[:raw]
        end
    end
  end
end
