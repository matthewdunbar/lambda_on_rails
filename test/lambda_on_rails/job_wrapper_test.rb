require 'test_helper'
require_relative 'test_job'

class JobWrapperTest < ActiveSupport::TestCase
  test 'it calls perform on the job' do
    job = LambdaOnRails::TestJob.new('arg1')
    data = Base64.encode64(job.serialize.to_json)

    event = {
      'Records' => [
        'body' => data
      ]
    }

    remote_job = Minitest::Mock.new
    remote_job.expect :perform, nil, ['arg1']

    LambdaOnRails::TestJob.stub(:new, remote_job) do
      handler(
        event: event, context: {}
      )
    end

    assert_mock remote_job
  end
end
