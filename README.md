# Tinytokenauth::Rails

This gem wants to help you with user authentication without bloating up beyond what
is required. It uses a JWT (JSON Web Token) in a cookie to store session state in the browser.

Since the JWT is signed with a secret, and this signature is verified server-side, the user can't
tamper with its contents. Its content is not encrypted, so frontend libraries can use this information
if they need to distinguish between 'signed in' vs 'signed out' state.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tinytokenauth-rails

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tinytokenauth-rails

## Usage

Include the module `Tinytokenauth::Authorizable` wherever you need to sign a user in/out or want to know if a user is signed in or not.
One option is to do this in `ApplicationController`, so the useful methods from this gem are available everywhere

```ruby
# app/controller/application_controller.rb
class ApplicationController < ActionController::Base
  include Tinytokenauth::Authorizable
  before_action :set_current_user
end
```

You will then have the user set in the variable `@current_user` or this will be nil if no user is signed in.

If a signed in user is required for some action, you can use the following pattern, the content of the block after
`require_current_user` is an example and depends on your project

```ruby
class PostsController < ApplicationController
  before_action ->{ require_current_user do
    # new_session_path is a route you need to setup same for the controller
    redirect_to new_session_path(forward_to: request.path), notice: "Please sign in again"
  end }, only: [:new, :create]
  # ...
end
```

User authentication need to be managed by yourself, afterwards you can leverage the helper method to sign the user in with the token

Below is an example how you can handle this yourself 

```ruby
class SessionsController < ApplicationController
  
  def new
  end

  def create
    user = User.find_by_email(params[:email]) # This depends on your use case
    if user&.authenticate(params[:password]) # This depends on your use case, this method comes from 'has_secure_password' in the model
      sign_in_with_token user # THIS IS FROM Tinytokenauth
      redirect_to params[:forward_to] || root_path, notice: 'Signed in!'
    else
      flash[:alert] = 'NOT signed in!'
      render 'new', status: :unauthorized
    end
  end

  def destroy
    sign_out_with_token # THIS IS FROM Tinytokenauth
    redirect_to params[:forward_to] || root_path, notice: 'Signed out!'
  end
end
```

If you want to configure the gem, please create a custom initializer like the one below. The values show below are the defaults

```ruby
# config/initializers/tinytokenauth.rb
require 'tinytokenauth'

Tinytokenauth.configure do |config|
  config.user_class = 'User' #  what is your modal that needs to be checked for a signed in user?
  config.token_validity_hours = 24 # how long should a token be valid?
  config.token_secret = Rails.application.credentials.secret_key_base # with which secret is the JWT signed?
  config.token_auto_renew_hours = 4 # if the token expires in less than X hours, renew it automatically
  config.cookie_name = 'ttauth' # what should be the name of the cookie that stores the auth information
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tinytokenauth-rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
