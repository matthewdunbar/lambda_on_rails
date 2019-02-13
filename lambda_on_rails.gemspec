$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "lambda_on_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "lambda_on_rails"
  spec.version     = LambdaOnRails::VERSION
  spec.authors     = ["Matthew Dunbar"]
  spec.email       = ["matthew.dunbar@lifeway.com"]
  spec.homepage    = "https://github.com/matthewdunbar/lambda_on_rails"
  spec.summary     = "AWS Lambda queue adapter for Active Job ."
  spec.description = "AWS Lambda queue adapter for Active Job ."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.2"
  spec.add_dependency "aws-sdk-sqs"
  spec.add_dependency "aws-sdk-lambda"
  spec.add_dependency "rubyzip"
  spec.add_development_dependency "sqlite3", "~> 1.3.6"
  spec.add_development_dependency "dotenv-rails"
  spec.add_development_dependency "pry"
end
