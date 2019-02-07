module LambdaOnRails
  class JobRunner
    attr_reader :queue_loader

    def initialize(queue_loader = ::LambdaOnRails::QueueLoader.new)
      @queue_loader = queue_loader
    end

    def enqueue(job)
      queue = queue_loader.get_queue(job.enqueue_url)
      queue.send_message(message_body: job.serialize.to_s)
    end
  end
end
