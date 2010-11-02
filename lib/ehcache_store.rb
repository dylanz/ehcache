require 'activesupport'
require 'ehcache/rails/ehcache_rails_common'

module ActiveSupport
  module Cache
    # Rails 2 cache store implementation which stores data in Ehcache:
    # http://www.ehcache.org/
    class EhcacheStore < Store
      include Ehcache::Rails

      def initialize(options = {})
        super
        @ehcache = self.create_cache   # This comes from the Ehcache::Rails mixin.
      end

      def read(key, options = nil)
        @ehcache.get(key)
      rescue Ehcache::EhcacheError => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      def write(key, value, options = nil)
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
