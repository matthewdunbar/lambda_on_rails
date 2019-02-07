class SampleJob < ApplicationJob

  self.queue_adapter = :lambda

  def enqueue_url
    'https://sqs.us-east-1.amazonaws.com/567419588983/rails_active_job'
  end
end
