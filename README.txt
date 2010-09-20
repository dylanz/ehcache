= Ehcache for JRuby

http://github.com/dylanz/ehcache

== DESCRIPTION:

Ehcache is a simplified JRuby interface to Java's (JSR-107 compliant) Ehcache.
Simplified meaning that it should work out-of-the-box, but a lot of native
methods haven't been interfaced yet, as they weren't needed.  Configuration
occurs in config/ehcache.yml, and should support all the configuration
options available.

Some biased and non-biased Ehcache VS Memcache articles:
http://gregluck.com/blog/archives/2007/05/comparing_memca.html
http://feedblog.org/2007/05/21/unfair-benchmarks-of-ehcache-vs-memcached
http://blog.aristotlesdog.com/2008/05/01/memcached_vs_ehcache/
http://www.hugotroche.com/my_weblog/2008/06/ehcache-vs-memc.html

For more information on Ehcache, see:
http://www.ehcache.org/

Configuration, Code Samples and everything else, see:
http://ehcache.org/documentation/index.html

Google Groups:
http://groups.google.com/group/ehcache-jruby

Tickets:
http://dylanz.lighthouseapp.com/projects/14518-ehcache-jruby/overview


== BASIC USAGE:

manager = CacheManager.new
cache = manager.cache
cache.put("key", "value", {:ttl => 120})
cache.get("key")
manager.shutdown


== RAILS:

Rails 2 and Rails 3 integration are provided by the separate ehcache-rails2
and ehcache-rails3 gems.  To install, choose the correct version for your
Rails application and use JRuby's gem command to install, e.g.:

$ jgem install ehcache-rails3
OR
$ jruby -S gem install ehcache-rails3


== REQUIREMENTS:

Tested with JRuby 1.5.0.


== INSTALL:

$ sudo jruby -S gem install ehcache


== LICENSE:
Copyright (c) 2008 Dylan Stamat <dstamat@elctech.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
