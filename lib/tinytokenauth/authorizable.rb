module Tinytokenauth

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  module Authorizable


    def authorize_with_header
      token = ''
      header = request.headers['Authorization']
      token = header.split(' ').last if header

      begin
        @decoded = JsonWebToken.decode(Tinytokenauth.configuration.token_secret, token)
        @current_user = Tinytokenauth.configuration.user_class.constantize.send 'find', @decoded[:user_id]
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end

    def require_current_user(&block)
      token = cookies[Tinytokenauth.configuration.cookie_name]
      begin
        @decoded = JsonWebToken.decode(Tinytokenauth.configuration.token_secret, token)
        @current_user = Tinytokenauth.configuration.user_class.constantize.send 'find', @decoded[:user_id]
        @exp = @decoded[:exp]
        if Tinytokenauth.configuration.token_auto_renew_hours &&
          @exp < Tinytokenauth.configuration.token_auto_renew_hours.hours.from_now.to_i
          sign_in @current_user
        end
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError => e
        if block_given? && current_user.nil?
          block.call
        else
          raise e
        end
      end
    end

    def set_current_user
      begin
        require_current_user
      rescue ActiveRecord::RecordNotFound
        # Ignored
      rescue JWT::DecodeError
        # Ignored
      end
      @current_user
    end

    def sign_in(user)
      @current_user = user
      jwt = JsonWebToken.encode(Tinytokenauth.configuration.token_validity_hours.hours.from_now,
                                Tinytokenauth.configuration.token_secret,
                                user_id: user.id,)
      cookies[Tinytokenauth.configuration.cookie_name] = jwt
    end

    def current_user
      @current_user
    end
  end
end