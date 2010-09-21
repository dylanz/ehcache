begin
  require 'ehcache'
rescue LoadError => e
  $stderr.puts "You don't have ehcache installed in your application. Please add it to your Gemfile and run bundle install"
  raise e
end
#require 'digest/md5'

module ActiveSupport
  module Cache
    # A cache store implementation which stores data in Ehcache:
    # http://www.ehcache.org/
    class EhcacheStore < Store

      def initialize(*args)
        super({})
        @data = Ehcache::CacheManager.new.cache
        extend Strategy::LocalCache
      end

      def increment(name, amount = 1, options = nil) # :nodoc:
        if num = @data.get(name)
          num = num.to_i + amount
          @data.put(name, num, options)
          num
        else
          nil
        end
      end

      def decrement(name, amount = 1, options = nil) # :nodoc:
        if num = @data.get(name)
          num = num.to_i - amount
          @data.put(name, num, options)
          num
        else
          nil
        end
      end

      def clear(options = nil)
        @data.remove_all
      end

      def stats
        @data.statistics
      end

      protected
      # Read an entry from the cache.
      def read_entry(key, options) # :nodoc:
        @data.get(key)
      rescue Ehcache::EhcacheError => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      # Write an entry to the cache.
      def write_entry(key, entry, options) # :nodoc:
        @data.set(key, entry, options)
        true
      rescue Ehcache::EhcacheError => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end

      # Delete an entry from the cache.
      def delete_entry(key, options) # :nodoc:
        @data.delete(key)
      rescue Exception => e
        logger.error("EhcacheError (#{e}): #{e.message}")
        false
      end
    end
  end
end
