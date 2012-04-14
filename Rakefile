require 'rake/testtask'
require 'rake/rdoctask'

require 'bundler'
Bundler::GemHelper.install_tasks(:name => 'jruby-ehcache')

task :default => [ :test ]

desc "Executes the test suite"
Rake::TestTask.new do |t|
  t.name = :test
  t.libs << 'lib' << 'ext' << 'test'
  t.pattern = "test/test_*.rb"
end
