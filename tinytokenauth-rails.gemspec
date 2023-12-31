# frozen_string_literal: true

require_relative "lib/tinytokenauth/version"

Gem::Specification.new do |spec|
  spec.name = "tinytokenauth-rails"
  spec.version = Tinytokenauth::VERSION
  spec.authors = ["Kim Laplume"]
  spec.email = ["klap@hey.com"]

  spec.summary = "Minimalistic JWT-based authentication that gets out of your way"
  spec.description = "This gem wants to help you with user authentication without bloating up beyond what
is required. It uses a JWT (JSON Web Token) in a cookie to store session state in the browser."
  spec.homepage = "https://github.com/1klap/tinytokenauth-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO not in use"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/1klap/tinytokenauth-rails/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "jwt", "~> 2.7"
  # spec.add_dependency "bcrypt", "~> 3.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
