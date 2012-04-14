# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ehcache/version"

require 'rake'

Gem::Specification.new do |s|
  s.name = "jruby-ehcache-rails2"
  s.version = Ehcache::VERSION
  s.authors = ["Dylan Stamat", "Jason Voegele"]
  s.summary = "Rails 2 cache store provider using Ehcache or BigMemory"
  s.description = "jruby-ehcache-rails2 a Rails 2 cache store provider that uses Ehcache or BigMemory as its backing store."
  s.email = ["dstamat@elctech.com", "jvoegele@terracotta.org"]
  s.homepage = "https://github.com/dylanz/ehcache"
  s.rubyforge_project = "ehcache"

  s.require_paths << 'ext'
  s.extra_rdoc_files = [
    "README.txt"
  ]

  s.files = FileList['*.txt', 'lib/active_support/**/*', 'lib/ehcache/active_support_store.rb']

  s.add_development_dependency('rake')
  s.add_runtime_dependency('jruby-ehcache', Ehcache::VERSION)
end

