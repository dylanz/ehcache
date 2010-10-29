begin
  require 'ehcache'
rescue LoadError => e
  $stderr.puts "You don't have ehcache installed in your application."
  $stderr.puts "Please add it to your Gemfile and run bundle install"
  raise e
end

module Ehcache
  # Mixin module providing facilities for the Rails 2 and Rails 3 Cache::Store
  # implementations.
  module Rails

    RAILS_CONFIG_DIR =
        if defined?(::Rails)
          File.join(::Rails.root.to_s, 'config')
        elsif defined?(RAILS_ROOT)
          File.join(RAILS_ROOT, 'config')
        end

    DEFAULT_RAILS_CACHE_NAME = 'rails_cache'

    def create_cache_manager(*args)
      config = Ehcache::Config::Configuration.find(RAILS_CONFIG_DIR)
      @cache_manager = Ehcache::CacheManager.create(config)
    end

    def create_cache(name = DEFAULT_RAILS_CACHE_NAME)
      create_cache_manager if @cache_manager.nil?
      @cache = @cache_manager.cache(name)
    end

    at_exit do
      @cache_manager.shutdown if @cache_manager
    end
  end
end
