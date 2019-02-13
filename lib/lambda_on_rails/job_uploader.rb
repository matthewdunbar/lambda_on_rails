require_relative './job_wrapper'
require 'aws-sdk-lambda'

module LambdaOnRails
  class JobUploader
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def upload
      create_queue unless queue_exists?

      if function_exists?
        update_lambda
      else
        create_lambda
      end

      create_event_source_mapping unless event_source_mapping_exists?
    end

    private

    def function_exists?
      lambda_client.get_function(function_name: job_identifier)

      true
    rescue Aws::Lambda::Errors::ResourceNotFoundException
      false
    end

    def queue_exists?
      sqs_client.get_queue_url(queue_name: "#{job_identifier}-Incoming")

      true
    rescue Aws::SQS::Errors::NonExistentQueue
      false
    end

    def event_source_mapping_exists?
      lambda_client.list_event_source_mappings(
        function_name: job_identifier
      ).event_source_mappings.any?
    end

    def create_lambda
      lambda_client.create_function(
        function_name: job_identifier,
        runtime: 'ruby2.5',
        role: klass.role_arn,
        code: {
          zip_file: zip_file
        },
        handler: 'job_wrapper.handler'
      )
    end

    def update_lambda
      lambda_client.update_function_code(
        function_name: job_identifier,
        zip_file: zip_file,
        publish: true
      )
    end

    def create_queue
      sqs_client.create_queue(queue_name: "#{job_identifier}-Incoming")
    end

    def create_event_source_mapping
      queue_url = sqs_client.get_queue_url(queue_name: "#{job_identifier}-Incoming").queue_url
      queue_attributes = sqs_client.get_queue_attributes(queue_url: queue_url, attribute_names: ["All"])

      lambda_client.create_event_source_mapping(
        event_source_arn: queue_attributes.attributes['QueueArn'],
        function_name: job_identifier
      )
    end

    def zip_file
      @zip_file ||= JobPackager.new.build_zip_file(klass).string
    end

    def job_identifier
      @job_identifier ||= klass.to_s.gsub(/[^0-9a-z ]/i, '-')
    end

    def lambda_client
      @lambda_client ||= Aws::Lambda::Client.new
    end

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new
    end
  end
end
