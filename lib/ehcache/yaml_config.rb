require 'java'
require 'ehcache'
require 'yaml'
require 'erb'

module Ehcache::Config
  module YamlConfig

    InvalidYamlConfiguration = Class.new(StandardError)

    # Not sure why, but "include Java::NetSfEhcacheConfig" does not work,
    # so define local constants referring to the Ehcache classes
    Configuration = Java::NetSfEhcacheConfig::Configuration
    CacheConfiguration = Java::NetSfEhcacheConfig::CacheConfiguration
    DiskStoreConfiguration = Java::NetSfEhcacheConfig::DiskStoreConfiguration
    FactoryConfiguration = Java::NetSfEhcacheConfig::FactoryConfiguration

    %w[name update_check monitoring dynamic_config
       disk_store transaction_manager event_listener
       peer_providers peer_listeners
       terracotta_config default_cache caches
       event_listeners extensions loaders decorators
    ].each do |attribute|
      const_set(attribute.upcase.to_sym, attribute)
    end

    def self.parse_yaml_config(yaml_config_file)
      YamlConfigBuilder.new(yaml_config_file).build
    end

    private

    class YamlConfigBuilder

      def initialize(yaml_file)
        @yaml_file = yaml_file
        @data = YAML.load(ERB.new(File.read(yaml_file)).result(binding))
        raise InvalidYamlConfiguration unless valid?(@data)
      end

      def build
        @config = Configuration.new
        for attribute in [NAME, UPDATE_CHECK, MONITORING, DYNAMIC_CONFIG]
          set_if_present(attribute)
        end
        set_disk_store
        set_transaction_manager
        set_event_listener
        add_peer_providers
        add_peer_listeners
        set_default_cache
        add_caches
        @config
      end

      private

      def valid?(data)
        data.is_a?(Hash)
      end

      def set_if_present(key)
        if @data.has_key?(key)
          setter = "#{key}=".to_sym
          @config.send(setter, @data[key])
        end
      end

      def set_attributes(object, attributes)
        attributes ||= []
        attributes.each do |key, value|
          if value.is_a?(Hash) || value.is_a?(Array)
            create_cache_config_factories(object, key, value)
          else
            object.send("#{key}=", value)
          end
        end
        object
      end

      def create_cache_config_factories(cache, key, value)
        [value].flatten.each do |data|
          create_cache_config_factory(cache, key, data)
        end
      end

      def create_cache_config_factory(cache, key, data)
        singular = key.singularize.sub(/s$/, '')
        factory_name = "Cache#{singular.camelize}Factory"
        class_name = "#{factory_name}Configuration"
        factory_class = CacheConfiguration.const_get(class_name)
        factory = factory_class.new

        method_name = "add#{factory_name}"

        cache.send(method_name, factory)
        set_attributes(factory, data)
      end

      def apply_config(key, config_class)
        if @data[key]
          [@data[key]].flatten.each do |data|
            config = config_class.new
            set_attributes(config, data)
            yield config
          end
        end
      end

      def set_disk_store
        apply_config(DISK_STORE, DiskStoreConfiguration) do |disk_store|
          @config.add_disk_store(disk_store)
        end
      end

      def set_transaction_manager
        apply_config(TRANSACTION_MANAGER, FactoryConfiguration) do |tx_mgr|
          @config.add_transaction_manager_lookup(tx_mgr)
        end
      end

      def set_event_listener
        apply_config(EVENT_LISTENER, FactoryConfiguration) do |event_listener|
          @config.addCacheManagerEventListenerFactory(event_listener)
        end
      end

      def add_peer_providers
        apply_config(PEER_PROVIDERS, FactoryConfiguration) do |peer_provider|
          @config.addCacheManagerPeerProviderFactory(peer_provider)
        end
      end

      def add_peer_listeners
        apply_config(PEER_LISTENERS, FactoryConfiguration) do |peer_listener|
          @config.addCacheManagerPeerListenerFactory(peer_listener)
        end
      end

      def set_default_cache
        apply_config(DEFAULT_CACHE, CacheConfiguration) do |cache_config|
          @config.default_cache_configuration = cache_config
        end
      end

      def add_caches
        apply_config(CACHES, CacheConfiguration) do |cache_config|
          @config.add_cache(cache_config)
        end
      end

      def create_factory_configuration(data)
        result = FactoryConfiguration.new
        set_attributes(result, data)
        result
      end
    end
  end
end
