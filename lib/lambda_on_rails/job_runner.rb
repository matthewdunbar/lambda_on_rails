module LambdaOnRails
  class JobRunner
    attr_reader :queue_loader

    def initialize(queue_loader = ::LambdaOnRails::QueueLoader.new)
      @queue_loader = queue_loader
    end

    def enqueue(job)
      queue = queue_loader.get_queue(job.enqueue_url)
      queue.send_message(message_body: Base64.encode64(job.serialize.to_json))
    end
  end
end
