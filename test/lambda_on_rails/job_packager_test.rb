require 'test_helper'
require_relative './test_job'
require 'zip'
require 'aws-sdk-lambda'

class LambdaOnRails::JobPackager::Test < ActiveSupport::TestCase
  test 'creates a zip file with the source code' do
    job_packager = ::LambdaOnRails::JobPackager.new

    job_packager.stub(:run_bundle_install, true, ['a']) do
      @zip_file = job_packager.build_zip_file(LambdaOnRails::TestJob)
    end

    Zip::File.open_buffer(@zip_file) do |data|
      job = data.select { |entry| entry.name == 'test_job.rb' }.first
      assert(job.get_input_stream.read.include?('class LambdaOnRails::TestJob < ActiveJob::Base'))

      job_wrapper = data.select { |entry| entry.name == 'job_wrapper.rb' }.first
      assert(job_wrapper.get_input_stream.read.include?('def handler'))
    end
  end
end
