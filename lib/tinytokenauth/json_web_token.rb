require 'jwt'

module Tinytokenauth
  class JsonWebToken
    def self.encode(exp, secret, payload)
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret)
    end

    def self.decode(secret, token)
      decoded = JWT.decode(token, secret)[0]
      HashWithIndifferentAccess.new decoded
    end
  end
end