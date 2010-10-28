require 'ehcache'

manager = Ehcache::CacheManager.new
cache = manager.cache

cache.put("answer", "42", {:ttl => 120})
answer = cache.get("answer")
puts "Answer: #{answer}"

question = cache.get("question") || 'unknown'
puts "Question: #{question}"

manager.shutdown