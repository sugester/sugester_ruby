require "sugester/version"
require 'aws-sdk'
require 'active_support/all'
require 'yaml'

class Sugester

  attr_accessor :sqs, :config, :url

  def self.local
    self.new YAML.load_file("/Users/sugester/projects/sugester_gem/sugester/secret.yml").deep_symbolize_keys
  end

  def initialize(config)
    @config = config
    @sqs = Aws::SQS::Client.new @config[:sqs][:config]
    #@url = @sqs.list_queues.queue_urls.first
    @url = @config[:sqs][:url]
  end

  def push msg
    @sqs.send_message({
      queue_url: @url,
      message_body: msg,
      message_attributes: {
        token: {
          string_value: @config[:token],
          data_type: "String",
        },
      },
    })
  end

end
