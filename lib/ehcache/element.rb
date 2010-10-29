# Enhance net.sf.ehcache.Element with a more Rubyesque API.
class Java::NetSfEhcache::Element
  def self.create(key, value, options = {})
    result = self.new(key, value)
    options.each do |key, value|
      setter = "#{key}=".to_sym
      result.send(setter, value) if result.respond_to?(setter)
    end
    result
  end

  alias tti getTimeToIdle
  alias ttl getTimeToLive

  alias tti= setTimeToIdle
  alias ttl= setTimeToLive
end

__END__
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
