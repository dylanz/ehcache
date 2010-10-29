require File.dirname(__FILE__) + '/test_helper.rb'

class TestConfiguration < Test::Unit::TestCase
  def setup
    @yaml_file = File.join(File.dirname(__FILE__), 'ehcache.yml')
    @config = Ehcache::Config::Configuration.create(@yaml_file)
  end

  must 'have valid top level attributes' do
    assert_equal('testing', @config.getName)
    assert_equal(false, @config.getUpdateCheck)
    assert_equal(Ehcache::Config::Configuration::Monitoring::AUTODETECT, @config.getMonitoring)
    assert_equal(true, @config.getDynamicConfig)
  end

  must 'have valid disk store configuration' do
    disk_store = @config.getDiskStoreConfiguration
    assert_not_nil(disk_store)
    assert_equal(java.lang.System.getProperty('java.io.tmpdir'),
                 disk_store.getPath)
  end

  must 'have valid transaction manager' do
    tx_mgr = @config.getTransactionManagerLookupConfiguration
    assert_factory_configuration_equals(tx_mgr,
        :class => 'net.sf.ehcache.transaction.manager.DefaultTransactionManagerLookup',
        :properties => 'jndiName=java:/TransactionManager',
        :property_separator => ';')
  end

  must 'have valid peer provider' do
    peer_providers = @config.getCacheManagerPeerProviderFactoryConfiguration
    assert_equal(1, peer_providers.size)
    peer_provider = peer_providers.first
    assert_factory_configuration_equals(peer_provider,
        :class => 'net.sf.ehcache.distribution.RMICacheManagerPeerProviderFactory',
        :properties => 'peerDiscovery=automatic,multicastGroupAddress=230.0.0.1,multicastGroupPort=4446,timeToLive=1',
        :property_separator => ',')
  end

  must 'have valid peer listener' do
    peer_listeners = @config.getCacheManagerPeerListenerFactoryConfigurations
    assert_equal(1, peer_listeners.size)
    peer_listener = peer_listeners.first
    assert_factory_configuration_equals(peer_listener,
        :class => 'net.sf.ehcache.distribution.RMICacheManagerPeerListenerFactory')
  end

  must 'have valid default cache' do
    default_cache = @config.getDefaultCacheConfiguration
    expected = {
        :getMaxElementsInMemory => 10000,
        :getTimeToLiveSeconds => 0,
        :getTimeToIdleSeconds => 0,
        :isOverflowToDisk => true,
        :isEternal => false,
        :getDiskSpoolBufferSizeMB => 30,
        :isDiskPersistent => false,
        :getDiskExpiryThreadIntervalSeconds => 120,
        :getMemoryStoreEvictionPolicy => Java::NetSfEhcacheStore::MemoryStoreEvictionPolicy::LRU
    }
    expected.each do |key, value|
      assert_equal(value, default_cache.send(key))
    end
  end

  must 'have two cache configurations' do
    caches = @config.getCacheConfigurations
    assert_equal(2, caches.size)
    assert(caches.containsKey("sampleCache1"), "Should have sampleCache1")
    assert(caches.containsKey("sampleCache2"), "Should have sampleCache2")
  end

  must 'have valid sampleCache1 configuration' do
    cache = @config.getCacheConfigurations['sampleCache1']
    expected = {
        :getMaxElementsInMemory => 10000,
        :getMaxElementsOnDisk => 1000,
        :getTimeToLiveSeconds => 1000,
        :getTimeToIdleSeconds => 360,
        :isOverflowToDisk => true,
        :isEternal => false
    }
    expected.each do |key, value|
      assert_equal(value, cache.send(key))
    end
  end

  must 'have valid sampleCache2 configuration' do
    cache = @config.getCacheConfigurations['sampleCache2']
    expected = {
        :getMaxElementsInMemory => 1000,
        :isOverflowToDisk => false,
        :isEternal => true,
        :isDiskPersistent => true
    }
    expected.each do |key, value|
      assert_equal(value, cache.send(key))
    end
  end

  private

  def assert_factory_configuration_equals(factory, values)
    assert_not_nil(factory)
    assert_kind_of(Hash, values)
    if values.has_key?(:class)
      assert_equal(values[:class], factory.getFullyQualifiedClassPath)
    end
    if values.has_key?(:properties)
      assert_equal(values[:properties], factory.getProperties)
    end
    if values.has_key?(:property_separator)
      assert_equal(values[:property_separator], factory.getPropertySeparator)
    end
  end
end
