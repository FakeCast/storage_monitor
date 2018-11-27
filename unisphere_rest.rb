class UnisphereRest
  require 'net/http'
  require 'openssl'
  
  attr_accessor :address, :path

  def initialize
    @address = address
    @path = path
  end

  @header = {
    'Authorization' => '%ENCODED AUTHORIZATION%',
    'Content-Type' => 'application/json',
    'Accept' => 'application/json'
  }

  def self.univmax_get(address, path, header=@header)
    http = Net::HTTP.new(address, 8443)
    #http.set_debug_output $stderr
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response =  http.get(path,header)
    return response.body
  end

  def self.univmax_post(address, path, header=@header, body)
    http = Net::HTTP.new(address, 8443)
    #http.set_debug_output $stderr
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response =  http.post(path, body.to_json, header)
    return response.body
  end

end
