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
  
  alias expires_in getTimeToLive
  def expires_in=(seconds)
    setTimeToLive(seconds.to_i)
  end
  alias expiresIn expires_in
  alias expiresIn= expires_in=
end
