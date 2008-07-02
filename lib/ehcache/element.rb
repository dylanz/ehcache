module Ehcache
  class Element
    attr_accessor :key, :value

    def initialize(key, value, options = {})
      @key     = key
      @value   = value
      @ttl     = options[:ttl] || nil

      element = Ehcache::Java::Element.new(key, value)
      element.set_time_to_live(@ttl) if @ttl
      @proxy = element
    end

    def ttl
      @ttl = @proxy.get_time_to_live
    end

    def tti
      @tti = @proxy.get_time_to_idle
    end

    def proxy
      @proxy
    end
  end
end
