# Common code used in the ehcache_store implementations for ActiveSupport 2.x and 3.x
require 'active_support'

begin
  require 'ehcache'
rescue LoadError => e
  $stderr.puts "You don't have ehcache installed in your application."
  $stderr.puts "Please add it to your Gemfile and run bundle install"
  raise e
end

# Base class for both the ActiveSupport 2 & 3 implementations
module Ehcache
  class ActiveSupportStore < ActiveSupport::Cache::Store

    cattr_accessor :config_directory
    cattr_accessor :default_cache_name

    attr_reader :cache_manager

    def create_cache_manager(options = {})
      config_dir = self.class.config_directory
      config = if options[:ehcache_config]
        File.expand_path(File.join(config_dir, options[:ehcache_config]))
      else
        Ehcache::Config::Configuration.find(config_dir) if config_dir
      end
      # Ehcache will use the failsafe configuration if nothing is passed in
      # Note: .create is a factory method
      @cache_manager = Ehcache::CacheManager.create(config)
    end

    def create_cache(options = {})
      create_cache_manager(options) if @cache_manager.nil?
      @cache_manager.cache(options[:cache_name] || default_cache_name)
    end

    def default_cache_name
      self.class.default_cache_name || 'app_cache'
    end

    at_exit do
      @cache_manager.shutdown if @cache_manager
    end

  end
end