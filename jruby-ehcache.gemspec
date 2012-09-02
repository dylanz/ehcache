# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ehcache/version"

Gem::Specification.new do |s|
  s.name = %q{jruby-ehcache}
  s.version = Ehcache::VERSION
  s.authors = [%q{Dylan Stamat}, %q{Jason Voegele}]
  s.description = %q{JRuby interface to the popular Java caching library Ehcache}
  s.email = [%q{dstamat@elctech.com}, %q{jvoegele@terracotta.org}]
  s.extra_rdoc_files = [ "README.txt" ]
  s.homepage = %q{http://ehcache.rubyforge.org}
  s.rubyforge_project = %q{ehcache}
  s.rubygems_version = %q{1.8.9}
  s.summary = %q{JRuby interface to Ehcache}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
