# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ehcache/version"

require 'rake'

Gem::Specification.new do |s|
  s.name = "jruby-ehcache"
  s.version = Ehcache::VERSION
  s.authors = ["Dylan Stamat", "Jason Voegele"]
  s.summary = "JRuby interface to Ehcache and BigMemory"
  s.description = "jruby-ehcache is a JRuby interface to the popular Java caching solution, Ehcache, as well as Terracotta's in-memory data management solution, BigMemory."
  s.email = ["dstamat@elctech.com", "jvoegele@terracotta.org"]
  s.homepage = "https://github.com/dylanz/ehcache"
  s.rubyforge_project = "ehcache"

  s.require_paths << 'ext'
  s.extra_rdoc_files = [
    "README.txt"
  ]

  s.files = FileList[
    "*.txt",
    "bin/*",
    "examples/*",
    "ext/**/*",
    "lib/**/*.rb",
    "script/*",
    "tasks/**/*"
  ]

  s.executables = ["ehcache"]

  s.add_development_dependency('rake')
  s.add_runtime_dependency('activesupport')
end

