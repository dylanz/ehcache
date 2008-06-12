module Ehcache
  module Config
    PRIMARY_CACHE_NAME = "cache"
    CONFIGURATION_FILE = "ext/ehcache-1.4.1/ehcache.xml"

    # standard tmpdir default
    @@default_disk  = {
      :path => "java.io.tmpdir"
    }

    # standard cache defaults
    @@default_cache = {
      :name => "default",
      :max_elements_in_memory => 10000,
      :eternal => false,
      :time_to_idle_seconds => 120,
      :time_to_live_seconds => 120,
      :overflow_to_disk => true,
      :disk_spool_buffer_size_mb => 30,
      :max_elements_on_disk => 1000000,
      :disk_persistent => false,
      :disk_expiry_thread_interval_seconds => 120,
      :memory_store_eviction_policy => "LRU"
    }

    # standard rmi/multicast discover
    @@default_peer_provider = {
      :class => "net.sf.ehcache.distribution.RMICacheManagerPeerProviderFactory",
      :properties => "peerDiscovery=automatic,multicastGroupAddress=230.0.0.1," +
        "multicastGroupPort=4446, timeToLive=1",
      :property_separator => ","
    }

    # standard listener
    @@default_peer_listener = {
      :class => "net.sf.ehcache.distribution.RMICacheManagerPeerListenerFactory"
    }

    # standard lack of event listener
    @@default_event_listener = {}

    class << self
      # instantiates default configuration as well as the primary
      # cache configuration used.  this is cheap bootstrap.
      def default
        configuration  = Ehcache::Java::Configuration.new
        disk_config    = Ehcache::Java::DiskStoreConfiguration.new
        cache_config   = Ehcache::Java::CacheConfiguration.new
        peer_provider  = Ehcache::Java::FactoryConfiguration.new
        peer_listener  = Ehcache::Java::FactoryConfiguration.new
        event_listener = Ehcache::Java::FactoryConfiguration.new

        # set all the defaults
        setter(disk_config,    @@default_disk)
        setter(cache_config,   @@default_cache)
        setter(peer_provider,  @@default_peer_provider)
        setter(peer_listener,  @@default_peer_listener)
        setter(event_listener, @@default_event_listener)

        # add the default and primary caches
        configuration.add_default_cache(cache_config)
        sample_cache_config = Ehcache::Java::CacheConfiguration.new
        setter(sample_cache_config, @@default_cache.merge({:name => PRIMARY_CACHE_NAME}))
        configuration.add_cache(sample_cache_config)

        # populate the configuration
        configuration.add_disk_store(disk_config)
        configuration.add_cache_manager_peer_provider_factory(peer_provider)
        configuration.add_cache_manager_peer_listener_factory(peer_listener)
        configuration.add_cache_manager_event_listener_factory(event_listener)
        configuration
      end

      # helper for setters
      def setter(factory, config)
        config.each { |k,v| factory.send("set_#{k.to_s}",v) }
      end
    end
  end
end
