unless $:.include?(File.dirname(__FILE__)) ||
       $:.include?(File.expand_path(File.dirname(__FILE__)))
  $:.unshift(File.dirname(__FILE__))
end

require 'java'

module Ehcache
  unless defined?(EHCACHE_HOME)
    EHCACHE_HOME = File.expand_path(File.dirname(__FILE__) + '/..')
  end

  # wraps all native exceptions
  class EhcacheError < RuntimeError; end
end

require 'ehcache/extensions'
require 'ehcache/java'
require 'ehcache/config'
require 'ehcache/cache'
require 'ehcache/cache_manager'
require 'ehcache/element'

if defined?(Rails)
  require 'ehcache/active_support_store'

  case Rails::VERSION::MAJOR
  when 2
    require 'active_support/ehcache_store' # AS 2 impl

    ActiveSupport::Cache::EhcacheStore.config_directory = File.expand_path(File.join(RAILS_ROOT, 'config'))
    ActiveSupport::Cache::EhcacheStore.default_cache_name = 'rails_cache'

  when 3
    require 'active_support/cache/ehcache_store' # AS 3 impl

    # Railtie
    module Ehcache
      class Railtie < ::Rails::Railtie
        initializer "ehcache.setup_paths" do
          ActiveSupport::Cache::EhcacheStore.config_directory = File.expand_path(File.join(::Rails.root, 'config'))
          ActiveSupport::Cache::EhcacheStore.default_cache_name = 'rails_cache'
        end
      end
    end

  end

end