module Ehcache
  Dir["#{Ehcache::EHCACHE_HOME}/ext/**/*.jar"].sort.each {|l| require l}

  include_package 'net.sf.ehcache'

  module Config
    include_package 'net.sf.ehcache.config'
  end

end
