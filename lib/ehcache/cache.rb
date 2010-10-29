# Enhance net.sf.ehcache.Cache with a more Rubyesque API.
class Java::NetSfEhcache::Cache
  include Enumerable

  # Yield each Element stored in this cache to the given block.  This method
  # uses Cache#getKeys as its basis, and therefore it is possible that some
  # of the yielded elements have expired.
  def each
    for key in self.getKeys
      yield self.get(key)
    end
  end
  # Gets an element value from the cache.  Unlike the #get method, this method
  # returns the element value, not the Element object.
  def [](key)
    element = self.get(key)
    element ? element.value : nil
  end

  alias ehcache_put put

  # Wrap the Cache#put method to allow for extra options to be passed to the
  # created Element.
  def put(*args)
    options = args.extract_options!
    if args.size == 1 && args.first.kind_of?(Ehcache::Element)
      element = args.first
    elsif args.size == 2
      element = Ehcache::Element.create(args[0], args[1], options)
    else
      raise ArgumentError, "Must be Element object or key and value arguments"
    end
    ehcache_put(element)
  end

  alias []= put

  alias include? isKeyInCache
  alias member? isKeyInCache

  # Atomic compare and swap for cache elements.  Invokes the given block with
  # the current value of the element and attempts to replace it with the
  # value returned from the block, repeating until replace returns true.
  # Note that the provided block works only with element values, not Element
  # objects: the result of element.getValue is passed to the block parameter,
  # and the block is expected to return a value based on it.
  # If there is no element with the given key, returns immediately without
  # retrying.
  def compare_and_swap(key, &block)
    begin
      old_element = self.get(key)
      return nil unless old_element
      new_element = Ehcache::Element.new(key, yield(old_element.value))
    end until replace(old_element, new_element)
  end

  alias update compare_and_swap
end
