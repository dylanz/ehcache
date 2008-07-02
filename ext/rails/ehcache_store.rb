require 'activesupport'
require 'ehcache'

module ActiveSupport
  module Cache
    class EhcacheStore < Store
      def initialize(options = {})
        manager = Ehcache::CacheManager.new(options)
        @data = manager.cache
      end

      def read(key, options = nil)
        super
        @data.get(key)
      rescue Ehcache::EhcacheError => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      def write(key, value, options = nil)
        super
        @data.set(key, value, options)
        true
      rescue Ehcache::EhcacheError => e
        logger.error("MemCacheError (#{e}): #{e.message}")
        false
      end

      def delete(key, options = nil)
        super
        @data.delete(key)
      rescue Exception => e
        logger.error("MemCacheError (#{e}): #{e.message}")
        false
      end

      def keys
        @data.keys
      end

      def exist?(key, options = nil)
        @data.exist?(key)
      end

      def delete_matched(matcher, options = nil)
        super
        raise "Not supported by Ehcache"
      end

      def clear
        @data.clear
        true
      rescue Exception => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end
    end
  end
end
