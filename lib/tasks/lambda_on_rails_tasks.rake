
desc 'Uploads ActiveJob code to AWS'
namespace :lambda_on_rails do
  task :upload, [:class_name] => :environment do |_task, args|
    job_class = args[:class_name].constantize
    job_uploader = LambdaOnRails::JobUploader.new(job_class)
    job_uploader.upload
  end
end
