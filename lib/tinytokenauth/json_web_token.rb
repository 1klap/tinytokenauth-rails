require 'jwt'

module Tinytokenauth
  class JsonWebToken
    # def self.encode(payload, exp = 24.hours.from_now, secret = Rails.application.credentials.secret_key_base)
    def self.encode(payload, options = {})
      exp = options[:exp]
      secret = options[:secret]
      puts exp
      puts exp.to_i
      puts payload
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret)
    end

    def self.decode(token, options = {})
      secret = options[:secret]
      decoded = JWT.decode(token, secret)[0]
      HashWithIndifferentAccess.new decoded
    end
  end
end