require 'test_helper'
require_relative './test_job'
require 'zip'
require 'aws-sdk-lambda'

class LambdaOnRails::JobUploader::Test < ActiveSupport::TestCase
  test 'creates a Lambda function and SQS queue' do
    job_uploader = ::LambdaOnRails::JobUploader.new(LambdaOnRails::TestJob)

    sqs_client = Minitest::Mock.new
    def sqs_client.get_queue_url(options)
      @count ||= 0
      @count += 1
      if @count > 1
        OpenStruct.new(queue_url: 'https://sqs')
      else
        raise Aws::SQS::Errors::NonExistentQueue.new(nil, nil)
      end
    end

    sqs_client.expect :create_queue, OpenStruct.new(queue_url: 'https://sqs'), [{
      queue_name: 'LambdaOnRails--TestJob-Incoming'
    }]

    sqs_client.expect :get_queue_attributes, OpenStruct.new(attributes: { 'QueueArn' => 'arn:test:queue' }), [{
      queue_url: 'https://sqs',
      attribute_names: ['All']
    }]

    lambda_client = Minitest::Mock.new
    def lambda_client.get_function(options); raise Aws::Lambda::Errors::ResourceNotFoundException.new(nil, nil) end
    lambda_client.expect :create_function, nil, [{
      function_name: 'LambdaOnRails--TestJob',
      code: {
        zip_file: 'ABCD'
      },
      runtime: 'ruby2.5',
      role: 'role:12345/us-east1',
      handler: 'job_wrapper.handler'
    }]

    lambda_client.expect :create_event_source_mapping, nil, [{
      event_source_arn: 'arn:test:queue',
      function_name: 'LambdaOnRails--TestJob'
    }]

    lambda_client.expect :list_event_source_mappings, OpenStruct.new(event_source_mappings: []), [{
      function_name: 'LambdaOnRails--TestJob'
    }]

    job_packager = Minitest::Mock.new
    job_packager.expect :build_zip_file, StringIO.new('ABCD'), [LambdaOnRails::TestJob]

    class LambdaOnRails::TestJob
      def self.role_arn; 'role:12345/us-east1' end
    end

    LambdaOnRails::JobPackager.stub(:new, job_packager) do
      Aws::SQS::Client.stub(:new, sqs_client) do
        Aws::Lambda::Client.stub(:new, lambda_client) do
          job_uploader.upload
        end
      end
    end

    assert_mock job_packager
    assert_mock lambda_client
    assert_mock sqs_client
  end
end
