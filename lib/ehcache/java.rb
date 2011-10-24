require 'java'

EHCACHE_LIBS_DIR = "#{Ehcache::EHCACHE_HOME}/ext"

module Ehcache
  module Rails
    RAILS_ROOT_DIR = if defined?(::Rails)
          ::Rails.root.to_s
        elsif defined?(RAILS_ROOT)
          RAILS_ROOT
        end
    if RAILS_ROOT_DIR
      RAILS_LIB_DIR = File.join(RAILS_ROOT_DIR, 'lib')
      Dir["#{RAILS_LIB_DIR}/**/*.jar"].each do |jar|
        $CLASSPATH << File.expand_path(jar)
      end
    end
  end
  Dir["#{EHCACHE_LIBS_DIR}/**/*.jar"].each do |jar|
    $CLASSPATH << File.expand_path(jar)
  end
  LOG = Java::OrgSlf4j::LoggerFactory.getLogger("JRubyEhcache")
  LOG.info("Using Ehcache version #{Java::NetSfEhcacheUtil::ProductInfo.new.getVersion()}")
=begin
  slf4j_loader = lambda { Java::OrgSlf4j::LoggerFactory.getLogger("JRubyEhcache") }
  begin
    LOG = slf4j_loader.call
    LOG.info("Using SLF4J Logger from CLASSPATH")
  rescue NameError
    Dir["#{EHCACHE_LIBS_DIR}/**/*slf4j*.jar"].each do |l| require l end
    LOG = slf4j_loader.call
    LOG.info("Using bundled SLF4J Logger")
  end

  ehcache_version_loader = lambda {
    Java::NetSfEhcacheUtil::ProductInfo.new.getVersion()
  }
  begin
    # If Ehcache is already on the classpath, use it.
    VERSION = ehcache_version_loader.call
    LOG.info("Using Ehcache #{VERSION} from CLASSPATH")
  rescue NameError
    # If not, use the Ehcache bundled with the jruby-ehcache gem.
    Dir["#{EHCACHE_LIBS_DIR}/**/*.jar"].each do |l|
      require l unless l =~ /slf4j/
    end
    VERSION = ehcache_version_loader.call
    LOG.info("Using bundled Ehcache #{VERSION}")
  end
=end
  include_package 'net.sf.ehcache'

  module Config
    include_package 'net.sf.ehcache.config'
  end

end
