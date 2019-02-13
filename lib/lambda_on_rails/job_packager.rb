require_relative './job_wrapper'
require 'zip'
require 'tmpdir'

module LambdaOnRails
  class JobPackager
    def build_zip_file(job_klass)
      temp_directory = build_tmp_directory(job_klass)
      Zip::OutputStream.write_buffer do |io|
        Dir[File.join(temp_directory, '**', '*')].each do |file|
          next if File.directory?(file)

          absolute_path = Pathname.new(file)
          relative_path = absolute_path.relative_path_from(Pathname.new(temp_directory))

          io.put_next_entry(relative_path)
          io.write(File.read(absolute_path))
        end
      end
    end

    private

    def build_tmp_directory(job_klass)
      directory = Dir.mktmpdir(job_klass.to_s.gsub(/[^0-9a-z ]/i, '-'))
      FileUtils.cp(class_source_location(job_klass), directory)
      FileUtils.cp(job_wrapper_source_location, directory)

      lambda_on_rails_path = '../../'

      File.write(File.join(directory, 'Gemfile'),
        <<~GEMFILE
          source 'https://rubygems.org'

          gem 'lambda_on_rails', path: "#{lambda_on_rails_path}"
        GEMFILE
      )

      run_bundle_install(directory)

      directory
    end

    def class_source_location(klass)
      klass.instance_method(:perform).source_location[0]
    end

    def class_source_code(klass)
      File.read(class_source_location(klass))
    end

    def job_wrapper_source_location
      method(:handler).source_location[0]
    end

    def job_wrapper_source_code
      File.read(job_wrapper_source_location)
    end

    def run_bundle_install(directory)
      Bundler.with_clean_env do
        system("cd #{directory}; docker run -v `pwd`:`pwd` -w `pwd` -i -t lambci/lambda:build-ruby2.5 bundle install")
        system("cd #{directory}; docker run -v `pwd`:`pwd` -w `pwd` -i -t lambci/lambda:build-ruby2.5 bundle install --deployment")
        # system("cd #{directory}; bundle install")
        # system("cd #{directory}; bundle install --deployment")
      end
    end
  end
end
