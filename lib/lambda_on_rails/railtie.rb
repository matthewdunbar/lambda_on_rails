module LambdaOnRails
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'tasks/lambda_on_rails_tasks.rake'
    end
  end
end
