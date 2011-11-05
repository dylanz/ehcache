require 'ehcache/active_support_store'

# Rails 3 cache store implementation which stores data in Ehcache:
# http://www.ehcache.org/

module ActiveSupport
  module Cache
    class EhcacheStore < Ehcache::ActiveSupportStore

      def initialize(*args)
        args = args.flatten
        options = args.extract_options!
        super(options)
        self.create_cache_manager(options)
        @ehcache = self.create_cache(options)
        extend Strategy::LocalCache
      end

      def increment(name, amount = 1, options = nil) # :nodoc:
        @ehcache.compare_and_swap(name) { |current_value|
          current_value + amount
        }
      end

      def decrement(name, amount = 1, options = nil) # :nodoc:
        @ehcache.compare_and_swap(name) { |current_value|
          current_value - amount
        }
      end

      def clear(options = nil)
        @ehcache.remove_all
      end

      def stats
        @ehcache.statistics
      end

      protected
      # Read an entry from the cache.
      def read_entry(key, options) # :nodoc:
        @ehcache[key]
      rescue Ehcache::EhcacheError => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      # Write an entry to the cache.
      def write_entry(key, entry, options) # :nodoc:
        @ehcache.put(key, entry, options)
        true
      rescue Ehcache::EhcacheError => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      # Delete an entry from the cache.
      def delete_entry(key, options) # :nodoc:
        @ehcache.remove(key)
      rescue Exception => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end
    end
  end
end
