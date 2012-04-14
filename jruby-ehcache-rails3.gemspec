# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ehcache/version"

Gem::Specification.new do |s|
  s.name = %q{jruby-ehcache-rails3}
  s.version = Ehcache::VERSION
  s.authors = [%q{Dylan Stamat}, %q{Jason Voegele}]
  s.date = %q{2012-03-14}
  s.description = %q{The Ehcache cache store provider for Rails 3}
  s.email = [%q{dstamat@elctech.com}, %q{jvoegele@terracotta.org}]
  s.extra_rdoc_files = [ "README.txt" ]
  s.homepage = %q{http://ehcache.rubyforge.org}
  s.rubyforge_project = %q{ehcache}
  s.rubygems_version = %q{1.8.9}
  s.summary = %q{Rails 3 cache store provider using Ehcache}

  s.files = `git ls-files`.split("\n").concat(
      ["lib/active_support/cache/ehcache_store.rb",
       "lib/ehcache/active_support_store.rb"])

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "i18n"
  s.add_runtime_dependency "jruby-ehcache"
end
