module Tinytokenauth

  module Authorizable
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end
    end

    def authorize_with_header
      token = ''
      header = request.headers['Authorization']
      token = header.split(' ').last if header

      begin
        @decoded = JsonWebToken.decode(token)
        # @current_user = User.find(@decoded[:user_id])
        @current_user = Authorizable.configuration.user_class.send 'find', @decoded[:user_id]
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end

    # def require_current_user(klass = User)
    #   token = cookies['klap-auth']
    #   # p "token from cookie: #{token}"
    #
    #   begin
    #     @decoded = JsonWebToken.decode(token)
    #     # @current_user = User.find(@decoded[:user_id])
    #     @current_user = klass.send 'find', @decoded[:user_id]
    #     @exp = @decoded[:exp]
    #     # if @exp < 24.hours.from_now.to_i # Always refresh token
    #     if @exp < 4.hours.from_now.to_i # Always refresh token
    #       sign_in @current_user
    #     end
    #   rescue ActiveRecord::RecordNotFound => e
    #     # TODO: evaluate if we should always forward
    #     redirect_to new_session_path(forward_to: request.path), notice: "Please sign in again" #, status: :unauthorized
    #   rescue JWT::DecodeError => e
    #     # TODO: evaluate if we should always forward
    #     # render json: { errors: e.message }, status: :unauthorized
    #     redirect_to new_session_path(forward_to: request.path), notice: "Please sign in again" #, status: :unauthorized
    #   end
    # end

    # def require_current_user2(klass = User, &block)
    #   current_user = set_current_user(klass)
    #   if block_given? && current_user.nil?
    #     block.call
    #   else
    #     raise MissingArgumentError
    #   end
    # end

    def require_current_user(&block)
      token = cookies[Authorizable.configuration.cookie_name]
      # p "token from cookie: #{token}"
      begin
        @decoded = JsonWebToken.decode(token)
        # @current_user = User.find(@decoded[:user_id])
        @current_user = Authorizable.configuration.user_class.send 'find', @decoded[:user_id]
        @exp = @decoded[:exp]
        if Authorizable.configuration.token_auto_renew_hours &&
          @exp < Authorizable.configuration.token_auto_renew_hours.hours.from_now.to_i
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

    # def set_current_user(klass = User)
    #   token = cookies[Authorizable.configuration.cookie_name]
    #   begin
    #     @decoded = JsonWebToken.decode(token)
    #     # @current_user = User.find(@decoded[:user_id])
    #     @current_user = klass.send 'find', @decoded[:user_id]
    #     @exp = @decoded[:exp]
    #     # if @exp < 24.hours.from_now.to_i # Always refresh token
    #     if @exp < 4.hours.from_now.to_i # Always refresh token
    #       # token = JsonWebToken.encode(user_id: @current_user.id)
    #       # cookies['klap-auth'] = token
    #       sign_in @current_user
    #     end
    #   rescue ActiveRecord::RecordNotFound
    #     # Ignored
    #   rescue JWT::DecodeError
    #     # Ignored
    #   end
    #   @current_user
    # end

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
      jwt = JsonWebToken.encode(user_id: user.id,
                                exp: Authorizable.configuration.token_validity_hours.hours.from_now,
                                secret: Authorizable.configuration.token_secret)
      cookies[Authorizable.configuration.cookie_name] = jwt
    end

    def current_user
      @current_user
    end
  end
end