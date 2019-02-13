load_paths = Dir["vendor/bundle/**/lib"]
$LOAD_PATH.unshift(*load_paths)

require 'base64'

def handler(event:, context:)
  system("bundle install --deployment")

  encoded_job = event['Records'][0]['body']
  serialized_job = JSON.parse(Base64.decode64(encoded_job))

  require_relative serialized_job['job_class'].underscore

  klass = Object.const_get(serialized_job['job_class'])

  job = klass.new
  job.perform(*serialized_job['arguments'])
end

class String
  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end
