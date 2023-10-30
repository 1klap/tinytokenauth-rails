module Tinytokenauth

  class Configuration
    attr_accessor :user_class, :token_validity_hours, :token_auto_renew_hours, :token_secret, :cookie_name

    def initialize
      @user_class = 'User'
      @token_validity_hours = 24
      @token_auto_renew_hours = 4
      @token_secret = Rails.application.credentials.secret_key_base
      @cookie_name = 'ttauth'
    end
  end
end