require 'java'

begin
  # If Ehcache is already on the classpath, use it.
  ehcache_version = Java::NetSfEhcacheUtil::ProductInfo.new.getVersion()
  puts("Using Ehcache #{ehcache_version} from CLASSPATH")
rescue NameError
  # If not, use the Ehcache bundled with the jruby-ehcache gem.
  Dir["#{Ehcache::EHCACHE_HOME}/ext/**/*.jar"].sort.each {|l| require l}
  ehcache_version = Java::NetSfEhcacheUtil::ProductInfo.new.getVersion()
  puts("Using bundled Ehcache #{ehcache_version}")
end

module Ehcache
  include_package 'net.sf.ehcache'

  module Config
    include_package 'net.sf.ehcache.config'
  end

end
