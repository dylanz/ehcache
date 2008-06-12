module Ehcache
  class Element
    attr_accessor :key, :value

    # simple constructor
    def initialize(key, value)
      @key   = key
      @value = value
    end
  end
end
