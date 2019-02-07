require 'test_helper'

class ActiveJob::QueueAdapters::LambdaAdapter::Test < ActiveSupport::TestCase
  test 'it sends the job to JobRunner' do
    job = ActiveJob::Base.new
    job_runner = Minitest::Mock.new
    job_runner.expect(:enqueue, true, [job])

    lambda_adapter = ActiveJob::QueueAdapters::LambdaAdapter.new(job_runner)

    lambda_adapter.enqueue(job)
    assert_mock job_runner
  end
end
