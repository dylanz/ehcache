begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

def defaults(gemspec)
  gemspec.rubyforge_project = 'ehcache'
  gemspec.homepage = "http://ehcache.rubyforge.org"
  gemspec.authors = ["Dylan Stamat", "Jason Voegele"]
  gemspec.email = ['dstamat@elctech.com', 'jvoegele@terracotta.org']
end

Jeweler::Tasks.new do |gemspec|
  defaults(gemspec)
  gemspec.name = "jruby-ehcache"
  gemspec.summary = "JRuby interface to Ehcache"
  gemspec.description = "JRuby interface to the popular Java caching library Ehcache"
  gemspec.files.exclude '.gitignore'

  # These files go in the ehcache-rails2 and ehcache-rails3 gems
  gemspec.files.exclude 'lib/ehcache_store.rb'
  gemspec.files.exclude 'lib/active_support/**/*'
end

Jeweler::Tasks.new do |gemspec|
  defaults(gemspec)
  gemspec.name = 'ehcache-rails3'
  gemspec.summary = 'Rails 3 cache store provider using Ehcache'
  gemspec.description = 'Rails 3 cache store provider using Ehcache'
  gemspec.files = 'lib/active_support/**/*'
  gemspec.test_files = []
  gemspec.add_dependency 'jruby-ehcache', ">=0.5.0"
end

Jeweler::Tasks.new do |gemspec|
  defaults(gemspec)
  gemspec.name = 'ehcache-rails2'
  gemspec.summary = 'Rails 2 cache store provider using Ehcache'
  gemspec.description = 'Rails 2 cache store provider using Ehcache'
  gemspec.files = 'lib/ehcache_store.rb'
  gemspec.test_files = []
  gemspec.add_dependency 'jruby-ehcache', ">=0.5.0"
end

Jeweler::GemcutterTasks.new
