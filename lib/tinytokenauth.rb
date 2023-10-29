# frozen_string_literal: true

module Tinytokenauth
  require_relative "tinytokenauth/version"
  require_relative "tinytokenauth/railtie"
  require_relative 'tinytokenauth/configuration'
  require_relative "tinytokenauth/authorizable"
  require_relative "tinytokenauth/view_helpers"

end

# module Tinytokenauth
#   module Rails
#     class Error < StandardError; end
#     # Your code goes here...
#   end
# end
