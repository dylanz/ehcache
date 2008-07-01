= ehcache

* FIX (url)

== DESCRIPTION:

Ehcache is a simplified JRuby interface to Java's Ehcache.
Simplified, meaning no Singleton support, and a ton of other small
things left out primarily because I didn't need them :P

A complete inteface would be grand, and contribution is welcome !

== FEATURES/PROBLEMS:

No Singleton support, and... probably more.

== SYNOPSIS:

manager = CacheManager.new
cache = manager.cache("cache")
cache.put("key", "value")
cache.get("key")

manager.shutdown


TODO:  Rails support
Run the ehcache_rails command from your projects root.  This will
install the needed ehcache_rails plugin, which adds the required
EhcacheStore cache store, and other rails'isms.


== REQUIREMENTS:

* FIX (list of requirements)

== INSTALL:

sudo gem install ehcache

== LICENSE:
...
