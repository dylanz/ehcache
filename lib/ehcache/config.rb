require 'ehcache/yaml_config'

# Enhance net.sf.ehcache.config.Configuration with a more Rubyesque API, and
# add support for using YAML for configuration.
class Java::NetSfEhcacheConfig::Configuration
  Factory = Java::NetSfEhcacheConfig::ConfigurationFactory

  # Searches for an Ehcache configuration file and, if found, returns a
  # Configuration object created from it.  The search algorithm looks for
  # files named "ehcache.yml" or "ehcache.xml", first looking in the provided
  # directories in order, and if not found there then looking in the Ruby
  # $LOAD_PATH.
  # Returns nil if no configuration file is found.
  def self.find(*dirs)
    file_names = %w[ehcache.yml ehcache.xml]
    dirs += $LOAD_PATH
    dirs.each do |dir|
      file_names.each do |name|
        candidate = File.join(dir, name)
        return create(candidate) if File.exist?(candidate)
      end
    end
    nil
  end

  def self.create(*args)
    result = nil
    case args.size
    when 0
      result = Factory.parseConfiguration()
    when 1
      arg = args.first

      if arg.is_a?(String)
        raise ArgumentError, "Cannot read config file '#{arg}'" unless File.readable?(arg)
        if arg =~ /\.yml$/
          result = Ehcache::Config::YamlConfig.parse_yaml_config(arg)
        else
          result = Factory.parseConfiguration(java.io.File.new(arg))
        end
      else
        result = Factory.parseConfiguration(arg)
      end
    end

    unless result.is_a?(self)
      raise ArgumentError, "Could not create Configuration from: #{args.inspect}"
    end
    result
  end
end

__END__
require 'erb'
require 'yaml'

module Ehcache

  class MissingConfigurationException < StandardError
    def initialize(search_dirs)
      super("Could not find Ehcache configuration file in any of: #{search_dirs.inspect}")
    end
  end

  # default configuration and a cache named "cache"
  # manager = Ehcache::CacheManager.new
  # cache   = manager.cache
  #
  # default configuration and a cache named "steve"
  # manager = Ehcache::CacheManager.new({"cache" => {"name" => "steve"}})
  # cache   = manager.cache("steve")
  class Config
    CONFIG_FILE_NAME = 'ehcache.yml'

    RAILS_CONFIG_DIR =
        if defined?(::Rails)
          File.join(::Rails.root.to_s, 'config')
        elsif defined?(RAILS_ROOT)
          File.join(RAILS_ROOT, 'config')
        end

    SEARCH_DIRS = [RAILS_CONFIG_DIR,
                   File.join(ENV['HOME'], 'lib', 'config'),
                   File.join(EHCACHE_HOME, 'config')].compact

    class << self
      def generate(options={})
        unless config_file = find_config_file
          raise MissingConfigurationException.new(SEARCH_DIRS)
        end
        config = ERB.new(File.open(config_file) {|f| f.read})
        config = YAML.load(config.result(binding))
        initialize_factory_proxies
        process(config, options)
      end

      private

      def find_config_file
        SEARCH_DIRS.map {|dir| File.join(dir, CONFIG_FILE_NAME)}.find { |f|
          File.readable?(f)
        }
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
        @configuration
      end

      # creates and installs default cache
      def create_default_cache(default)
        default_cache_config = create_cache_configuration("default", default)
        @configuration.add_default_cache(default_cache_config)
      end

      # creates and installs primary cache
      def create_primary_cache(primary)
        primary_cache_config = create_cache_configuration("cache", primary)
        @configuration.add_cache(primary_cache_config)
      end

      # creates and sets up cache configurations
      def create_cache_configuration(cache_name, data)
        config = instance_variable_get("@#{cache_name}".intern)
        data.each { |k,v|
          # included hashes will be event listener factories, exception handler
          # factories, loader factories, etc.  TODO:  clean this up, and add
          # support for adding other factories in a cleaner fashion.
          if v.is_a?(Hash)
            case k
              when "event_listener":
                event_factory = Ehcache::Java::CacheConfiguration::CacheEventListenerFactoryConfiguration.new(config)
                v.each { |k,v| event_factory.send("set_#{k.to_s}",v) }
                config.add_cache_event_listener_factory(event_factory)
              when "bootstrap_loader":
                bootstrap_loader = Ehcache::Java::CacheConfiguration::BootstrapCacheLoaderFactoryConfiguration.new(config)
                v.each { |k,v| bootstrap_loader.send("set_#{k.to_s}",v) }
                config.add_bootstrap_cache_loader_factory(bootstrap_loader)
            end
          else
            config.send("set_#{k.to_s}",v)
          end
        }
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
      end

      # helper for setters
      def setter(factory, config)
        factory = instance_variable_get("@#{factory}".intern)
        config.each { |k,v| factory.send("set_#{k.to_s}",v) unless v.is_a?(Hash) }
      end
    end
  end
end
