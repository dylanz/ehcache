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
