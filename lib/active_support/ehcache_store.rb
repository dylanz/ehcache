require 'ehcache/active_support_store'

# Rails 2 cache store implementation which stores data in Ehcache:
# http://www.ehcache.org/

module ActiveSupport
  module Cache
    class EhcacheStore < Ehcache::ActiveSupportStore

      def initialize(options = {})
        super() # Rails 2.3.x Store doesn't take any arguments to initialize
        @ehcache = self.create_cache
      end

      def read(key, options = nil)
        @ehcache[key]
      rescue Ehcache::EhcacheError => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      def write(key, value, options = {})
        @ehcache.put(key, value, options)
        true
      rescue Ehcache::EhcacheError => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      def delete(key, options = nil)
        @ehcache.remove(key)
      rescue Exception => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      def keys
        @ehcache.keys
      end

      def exist?(key, options = nil)
        @ehcache.exist?(key)
      end

      def delete_matched(matcher, options = nil)
        super
        raise "Not supported by Ehcache"
      end

      def clear
        @ehcache.clear
        true
      rescue Exception => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end
    end
  end
end
