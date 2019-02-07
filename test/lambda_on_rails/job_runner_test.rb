require 'test_helper'

class LambdaOnRails::JobRunner::Test < ActiveSupport::TestCase
  test 'it adds a job to an SQS queue' do
    queue = Minitest::Mock.new
    queue.expect(
      :send_message,
      true,
      [
        {
          message_body: '{}'
        }
      ]
    )

    job = Minitest::Mock.new
    job.expect :enqueue_url, 'https://example.com'
    job.expect :serialize, {}

    queue_loader = Minitest::Mock.new
    queue_loader.expect :get_queue, queue, ['https://example.com']

    job_runner = LambdaOnRails::JobRunner.new(queue_loader)

    job_runner.enqueue(job)

    assert_mock queue_loader
    assert_mock queue
    assert_mock job
  end
end
