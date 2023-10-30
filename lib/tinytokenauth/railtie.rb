module Tinytokenauth
  class Railtie < ::Rails::Railtie
    initializer "tinytokenauth-rails.view_helpers" do
      ActiveSupport.on_load(:action_view) do
        include ViewHelpers
      end
    end
  end
end
