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

  alias element_value value

  # Wrap the Element#value method to unmarshal Ruby objects if necessary.
  def value
    val = element_value
    if val.kind_of?(Java::NetSfEhcache::MarshaledRubyObject)
      Marshal.load(String.from_java_bytes(val.bytes))
    else
      val
    end
  end

  alias tti getTimeToIdle
  alias ttl getTimeToLive

  alias tti= setTimeToIdle
  alias ttl= setTimeToLive
  
  alias expires_in getTimeToLive
  def expires_in=(seconds)
    setTimeToLive(seconds.to_i)
  end
  alias expiresIn expires_in
  alias expiresIn= expires_in=
end
