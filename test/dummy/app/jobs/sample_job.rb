class SampleJob < ActiveJob::Base

  self.queue_adapter = :lambda

  def perform(name)
    puts "Hello #{name}, how ya doin?"
  end

  def enqueue_url
    'https://sqs.us-east-1.amazonaws.com/789533204773/SampleJob-Incoming'
  end

  def self.role_arn
    'arn:aws:iam::789533204773:role/lambda_sqs_basic_execution'
  end
end
