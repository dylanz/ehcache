require 'java'
require 'ehcache'
require 'yaml'
require 'erb'

module Ehcache::Config
  # Support for using YAML for Ehcache configuration.
  # YAML configuration is similar to XML configuration, but there are some
  # changes to the names of configuration elements to make them simpler or
  # more idiomatic to Ruby and YAML conventions.  The changes are described
  # below.  For full documentation on the Ehcache configuration elements,
  # see the Ehcache Cache Configuration documentation:
  # http://ehcache.org/documentation/configuration.html
  #
  # The top level YAML configuration attributes and the corresponding XML
  # elements or attributes are shown in the following table.
  #
  # name:: name attribute on ehcache element
  # update_check:: updateCheck attribute on ehcache element
  # monitoring:: monitoring attribute on ehcache element
  # dynamic_config:: dynamicConfig attribute on ehcache element
  # disk_store:: diskStore element
  # transaction_manager:: transactionManagerLookup element
  # event_listener:: cacheManagerEventListenerFactory element
  # peer_providers (Array):: cacheManagerPeerProviderFactory elements
  # peer_listeners (Array):: cacheManagerPeerListenerFactory elements
  # terracotta_config:: terracottaConfig element
  # default_cache:: defaultCache element
  # caches (Array):: cache elements
  #
  # Each top level configuration attribute contains a set of key/value pairs
  # that are equivalent to the Ehcache XML attributes, except that the
  # attribute names are converted to use underscore_names instead of
  # camelCaseNames.  For instance, the Ehcache XML attribute
  # diskSpoolBufferSizeMB becomes disk_spool_buffer_size_mb in YAML.
  #
  # Entries in the above table that are marked as (Array) should be YAML lists
  # to allow for multiple values.  So, for example, to configure multiple
  # caches in your YAML configuration, use the following syntax:
  #
  #   caches:
  #     - name: my_cache
  #       time_to_idle_seconds: 360
  #       time_to_live_seconds: 1000
  #     - name: my_other_cache
  #       max_elements_in_memory: 1000
  #       eternal: true
  #       overflow_to_disk: false
  #       disk_persistent: true
  #
  # Note the use of the '-' to separate list elements.
  #
  # One further difference between YAML configuration and XML configuration
  # deals with cache configuration.  The XML configuration allows for a set
  # of XML sub elements to configure various aspects of caches (or the default
  # cache).  In YAML, these sub elements are translated to attributes within
  # the cache configuration (or default_cache configuration) that
  # refer to Hashes or Arrays.  The following table shows the mapping.
  #
  # event_listeners (Array):: cacheEventListenerFactory sub elements
  # extensions (Array):: cacheExtensionFactory sub elements
  # loaders (Array):: cacheLoaderFactory sub elements
  # decorators (Array):: cacheDecoratorFactory sub elements
  # bootstrap_loader (Hash):: bootstrapCacheLoaderFactory sub element
  # exception_handler (Hash):: cacheExceptionHandlerFactory sub element
  # terracotta (Hash):: terracotta sub element
  # cache_writer (Hash):: cacheWriter sub element
  # copy_strategy (Hash):: copyStrategy sub element
  #
  # Those marked as (Array) may take a list of values, while those marked as
  # (Hash) may take a single Hash value (set of key/value pairs).  Here is an
  # example of a cache configuration that uses one of each style:
  #
  #   caches:
  #     - name: some_cache
  #       time_to_live_seconds: 100
  #       event_listeners:
  #         - class: net.sf.ehcache.distribution.RMICacheReplicatorFactory
  #           properties: "replicateAsynchronously=false"
  #       copy_strategy:
  #         class: net.sf.ehcache.store.compound.SerializationCopyStrategy
  #
  # Note again the use of the '-' character to separate list elements in the
  # case of Array values, which is not present for Hash values.
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

    # Parses the given yaml_config_file and returns a corresponding
    # Ehcache::Config::Configuration object.
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

      def names_for_factory(key)
        singular = key.singularize.sub(/s$/, '')
        factory_name = if key == 'bootstrap_loader'
          "BootstrapCacheLoaderFactory"
        else
          "Cache#{singular.camelize}Factory"
        end
        class_name = "#{factory_name}Configuration"
        method_name = "add#{factory_name}"
        return [class_name, method_name]
      end

      def create_cache_config_factory(cache, key, data)
        class_name, method_name = names_for_factory(key)
        factory_class = CacheConfiguration.const_get(class_name)
        factory = factory_class.new

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
