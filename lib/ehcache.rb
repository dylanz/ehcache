unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  $:.unshift(File.dirname(__FILE__)) 
end

require 'java'

module Ehcache
  unless defined?(EHCACHE_HOME)
    EHCACHE_HOME = File.expand_path(File.dirname(__FILE__) + '/..')
  end

  # wraps all native exceptions
  class EhcacheError < RuntimeError; end
end

require 'ehcache/java'
require 'ehcache/config'
require 'ehcache/cache'
require 'ehcache/cache_manager'
require 'ehcache/element'
require 'ehcache/extensions'
require 'ehcache/version'
