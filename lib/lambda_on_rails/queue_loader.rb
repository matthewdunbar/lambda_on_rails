require 'aws-sdk-sqs'

module LambdaOnRails
  class QueueLoader
    def get_queue(url)
      Aws::SQS::Queue.new(url)
    end
  end
end
