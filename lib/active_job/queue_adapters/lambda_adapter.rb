module ActiveJob
  module QueueAdapters
    class LambdaAdapter
      attr_reader :job_runner

      def initialize(job_runner = ::LambdaOnRails::JobRunner.new)
        @job_runner = job_runner
      end

      def enqueue(job)
        job_runner.enqueue(job)
      end
    end
  end
end
