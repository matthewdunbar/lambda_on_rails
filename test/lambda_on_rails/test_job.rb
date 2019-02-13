class LambdaOnRails::TestJob < ActiveJob::Base
  def perform
    puts 'Hello World'
  end
end
