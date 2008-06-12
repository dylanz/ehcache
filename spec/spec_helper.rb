require 'rubygems'
require 'spec'
require 'spec/story'
require 'java'

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib ehcache]))
include Ehcache
include Ehcache::Java

Spec::Runner.configure do |config|
  #config.mock_with :mocha
end
