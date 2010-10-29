require 'java'
require 'ehcache'
require 'yaml'
require 'erb'

module Ehcache::Config
  module YamlConfig
    # Not sure why, but "include Java::NetSfEhcacheConfig" does not work,
    # so define local constants referring to the Ehcache classes
    Configuration = Java::NetSfEhcacheConfig::Configuration
    CacheConfiguration = Java::NetSfEhcacheConfig::CacheConfiguration
    DiskStoreConfiguration = Java::NetSfEhcacheConfig::DiskStoreConfiguration
    FactoryConfiguration = Java::NetSfEhcacheConfig::FactoryConfiguration

    TOP_LEVEL_ATTRIBUTES = %w[
        name update_check monitoring dynamic_config disk_store
        transaction_manager event_listener peer_providers peer_listeners
        terracotta_config default_cache caches
    ]
    TOP_LEVEL_ATTRIBUTES.each do |attribute|
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

      def set_if_present(key)
        if @data.has_key?(key)
          setter = "#{key}=".to_sym
          @config.send(setter, @data[key])
        end
      end

      def set_attributes(object, attributes)
        attributes ||= []
        attributes.each do |key, value|
          object.send("#{key}=", value)
        end
        object
      end

      def set_disk_store
        disk_store = DiskStoreConfiguration.new
        set_attributes(disk_store, @data[DISK_STORE])
        @config.add_disk_store(disk_store)
      end

      def set_transaction_manager
        if @data[TRANSACTION_MANAGER]
          tx_mgr = create_factory_configuration(@data[TRANSACTION_MANAGER])
          @config.transactionManagerLookup(tx_mgr)
        end
      end

      def set_event_listener
        if @data[EVENT_LISTENER]
          event_listener = create_factory_configuration(@data[EVENT_LISTENER])
          @config.addCacheManagerEventListenerFactory(event_listener)
        end
      end

      def add_peer_providers
        if @data[PEER_PROVIDERS]
          @data[PEER_PROVIDERS].each do |data|
            peer_provider = create_factory_configuration(data)
            @config.addCacheManagerPeerProviderFactory(peer_provider)
          end
        end
      end

      def add_peer_listeners
        if @data[PEER_LISTENERS]
          @data[PEER_LISTENERS].each do |data|
            peer_listener = create_factory_configuration(data)
            @config.addCacheManagerPeerListenerFactory(peer_listener)
          end
        end
      end

      def set_default_cache
        cache_config = CacheConfiguration.new
        set_attributes(cache_config, @data[DEFAULT_CACHE])
        @config.default_cache_configuration = cache_config
      end

      def add_caches
        if @data[CACHES]
          @data[CACHES].each do |data|
            cache_config = CacheConfiguration.new
            set_attributes(cache_config, data)
            @config.addCache(cache_config)
          end
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
