module Tinytokenauth
  module Rails
    class Engine < Rails::Engine
      initializer "tinytokenauth-rails.view_helpers" do
        ActiveSupport.on_load(:action_view) do
          include ViewHelpers
        end
      end
    end
  end
end