module Ehcache
  module Java
    include Java
    Dir["#{Ehcache::EHCACHE_HOME}/ext/**/*.jar"].sort.each {|l| require l}
    include_package "net.sf.ehcache"
    include_package "net.sf.ehcache.config"
  end
end
