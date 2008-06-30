require 'erb'
require 'yaml'

module Ehcache

  # default configuration and a cache named "primary"
  # manager = Ehcache::CacheManager.new
  # cache   = manager.cache
  #
  # default configuration and a cache named "steve"
  # manager = Ehcache::CacheManager.new({"cache" => {"name" => "steve"}})
  # cache   = manager.cache("steve")
  class Config
    CONFIGURATION_FILE = EHCACHE_HOME + "/config/ehcache.yml"

    class << self
      def generate(options={})
        unless File.exists?(CONFIGURATION_FILE)
          raise CONFIGURATION_FILE + " must exist"
        end
        config = ERB.new(File.open(CONFIGURATION_FILE) {|f| f.read})
        config = YAML.load(config.result(binding))
        initialize_factory_proxies
        process(config, options)
      end

      def process(config, options)
        # merge in new defaults if any
        config["default"].deep_merge!(options["default"]) if options["default"]
        
        # primary cache should be based off of default cache
        config["cache"] = config["default"].merge({"name" => Ehcache::Cache::PRIMARY})

        # update the rest of the configuration
        config.deep_merge!(options) if options
        config.each { |key, value| setter(key, value) }

        # add default cache and primary cache if present
        create_default_cache(config["default"])
        create_primary_cache(config["cache"]) if config["cache"]

        # populate the configuration
        @configuration.add_disk_store(@disk)
        @configuration.add_cache_manager_peer_provider_factory(@peer_provider)
        @configuration.add_cache_manager_peer_listener_factory(@peer_listener)
        @configuration.add_cache_manager_event_listener_factory(@event_listener)
        @configuration
      end

      # creates and installs default cache
      def create_default_cache(default)
        default_cache_config = create_cache_configuration(default)
        @configuration.add_default_cache(default_cache_config)
      end

      # creates and installs primary cache
      def create_primary_cache(primary)
        primary_cache_config = create_cache_configuration(primary)
        @configuration.add_cache(primary_cache_config)
      end

      # creates and sets up cache configurations
      def create_cache_configuration(data)
        config = Ehcache::Java::CacheConfiguration.new
        data.each { |k,v| config.send("set_#{k.to_s}",v) }
        config
      end

      # initialize all the java factory proxies for configuration
      def initialize_factory_proxies
        @configuration  = Ehcache::Java::Configuration.new
        @disk           = Ehcache::Java::DiskStoreConfiguration.new
        @cache          = Ehcache::Java::CacheConfiguration.new
        @default        = Ehcache::Java::CacheConfiguration.new
        @peer_provider  = Ehcache::Java::FactoryConfiguration.new
        @peer_listener  = Ehcache::Java::FactoryConfiguration.new
        @event_listener = Ehcache::Java::FactoryConfiguration.new
      end

      # helper for setters
      def setter(factory, config)
        factory = instance_variable_get("@#{factory}".intern)
        config.each { |k,v| factory.send("set_#{k.to_s}",v) }
      end
    end
  end
end
