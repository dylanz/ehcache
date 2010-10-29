require File.dirname(__FILE__) + '/test_helper.rb'

class TestConfiguration < Test::Unit::TestCase
  def setup
    create_config
  end

  def test_is_a_real_ehcache_java_configuration_object
    assert_valid_configuration(@config)
  end

  must 'initialize with ehcache.xml' do
    create_config(File.join(File.dirname(__FILE__), 'ehcache.xml'))
    assert_valid_configuration(@config)
    assert_not_nil(@config.configuration_source)
    cache_configs = @config.cache_configurations
    assert_equal(2, cache_configs.size)
  end

  private

  def create_config(*args)
    @config = Ehcache::Config::Configuration.create(*args)
  end

  def assert_valid_configuration(config)
    assert_kind_of(Java::NetSfEhcacheConfig::Configuration, config)
  end
end
