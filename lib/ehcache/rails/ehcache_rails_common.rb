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
    root = defined?(::Rails.root) ? ::Rails.root : RAILS_ROOT
    RAILS_CONFIG_DIR = File.join(root, 'config')

    DEFAULT_RAILS_CACHE_NAME = 'rails_cache'

    attr_reader :cache_manager

    def create_cache_manager(options = {})
      config = nil
      if options[:ehcache_config]
        Dir.chdir(RAILS_CONFIG_DIR) do
          config = File.expand_path(options[:ehcache_config])
        end
      else
        config = Ehcache::Config::Configuration.find(RAILS_CONFIG_DIR)
      end
      @cache_manager = Ehcache::CacheManager.create(config)
    end

    def create_cache(options = {})
      create_cache_manager(options) if @cache_manager.nil?

      @cache = @cache_manager.cache(options[:cache_name] || DEFAULT_RAILS_CACHE_NAME)
    end

    at_exit do
      @cache_manager.shutdown if @cache_manager
    end
  end
end
