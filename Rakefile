require "bundler/gem_helper"
Bundler::GemHelper.install_tasks :name => "jruby-ehcache"

task :default => [ :test ]

require 'rdoc/task'
require 'rake/testtask'
desc "Executes the test suite"
Rake::TestTask.new do |t|
  t.name = :test
  t.libs << 'lib' << 'ext' << 'test'
  t.pattern = "test/test_*.rb"
end
