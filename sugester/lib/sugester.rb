require "sugester/version"
require 'aws-sdk'
require 'active_support/all'
require 'yaml'

class Sugester

  attr_accessor :sqs, :config, :url

  def initialize(config)
    @config = config
    @sqs = Aws::SQS::Client.new @config[:sqs][:config]
    #@url = @sqs.list_queues.queue_urls.first
    @url = @config[:sqs][:url]
    @api_token = @config[:api_token]
    #@encoded_api_token = Digest::MD5.hexdigest @api_token #for js
  end

  def push activity_name, client_id = nil
    #TODO assert client_id
    msg = {
      queue_url: @url,
      message_body: activity_name,
      message_attributes: {
        api_token: {
          string_value: @api_token,
          data_type: "String",
        },
      },
    }
    if client_id
      msg[:message_attributes][:client_id] = {
        string_value: client_id.to_s,
        data_type: "Number",
      }
    end
    @sqs.send_message(msg)
  end

  def self.init_singleton(config)
    @@singleton = Sugester.new config
  end

  def self.push *args
    @@singleton.push *args
  end

end
