# Enhance net.sf.ehcache.Cache with a more Rubyesque API.
class Java::NetSfEhcache::Cache
  # Gets an element value from the cache.  Unlike the #get method, this method
  # returns the element value, not the Element object.
  def [](key)
    element = self.get(key)
    element ? element.value : nil
  end

  alias ehcache_put put

  # Wrap the Cache#put method to allow for extra options.
  def put(key, value, options={})
    if key.nil? || key.empty?
      raise EhcacheError, "Element cannot be blank"
    end
    element = Ehcache::Element.create(key, value, options)
    ehcache_put(element)
  end

  alias []= put
end
