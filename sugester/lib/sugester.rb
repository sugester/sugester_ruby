require "sugester/version"
require 'aws-sdk'
require 'active_support/all'
require 'digest'

module Sugester

  class SugesterQueue

    def self.decrypt(msg)
      begin
        cipher = OpenSSL::Cipher.new('AES-128-ECB')
        cipher.decrypt()
        cipher.key = "JKLGHJFHGFUOYTIUKYGbhjgvcutytfiCktyD845^8^f6d%df65*I"
        tempkey = Base64.decode64(URI.decode(msg))
        crypt = cipher.update(tempkey)
        crypt << cipher.final()
      rescue
        crypt = nil
      end
      return crypt
    end

    def config(property)
      JSON.parse(SugesterQueue.decrypt(@secret)).deep_symbolize_keys[property]
    rescue JSON::ParserError => e
      raise "secret corrupted"
    end

    def initialize(secret)
      @secret = secret
      @sqs = Aws::SQS::Client.new(config(:config))
    end

    def activity(client_id, activity_name, options = {})
      #TODO assert client_id
      msg = {
        activity: activity_name,
        client_id: client_id,
        token: config(:token),
        prefix: config(:prefix),
      }
      #TODO max length
      @sqs.send_message({
        queue_url: config(:url),
        message_body: msg.to_json,
      })
    end
  end

  def self.init_singleton *args
    @@singleton = SugesterQueue.new *args
  end

  def self.activity *args
    @@singleton.activity *args
  end

end
