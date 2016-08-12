require 'aws-sdk'
require 'active_support/all'
require 'digest'

module Sugester

  VERSION = "0.5.1"

  def self.assert(msg, v)
    raise StandardError.new(msg) unless v
  end
  def self.instance_assert(variable_name, variable, *klasses)
    assert(
      "#{variable_name} must be instance of #{klasses.join(" or ")}",
      klasses.reduce(false){|acc, klass| acc || (variable.is_a? klass)}
    )
  end

  class SugesterQueue

    private

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


    def push(kind, client_id, msg)
      Sugester.assert "unknown kind", MSG_KINDS.include?(kind)
      Sugester.instance_assert "client_id", client_id, Integer
      raw_push msg.merge({client_id: client_id, kind: kind})
    end

    def raw_push(msg)
      #TODO max length
      @sqs.send_message({
        queue_url: config(:url),
        message_body: msg.merge({
            token: config(:token),
            prefix: config(:prefix),
          }).to_json,
      })
    end

    MSG_KINDS = [:activity, :property, :payment]
    public

    def initialize(secret)
      @secret = secret
      @sqs = Aws::SQS::Client.new(config(:config))
    end

    def activity(client_id, name, options = {})
      Sugester.instance_assert "name", name, String, Symbol
      push :activity, client_id, {name: name}
    end

    def property(client_id, options)
      options.each do |name, value|
        Sugester.instance_assert "name", name, String, Symbol
        #TODO valid value
      end
      push :property, client_id, {options: options}
    end

    def payment(client_id, name, price, date_from, date_to)
      Sugester.instance_assert "date_from", date_from, Time
      Sugester.instance_assert "date_to", date_to, Time
      Sugester.instance_assert "price", price, Numeric
      Sugester.instance_assert "name", name, String, Symbol

      push :payment, client_id, {price: price, from: date_from, to: date_to, name: name}
    end
  end

  def self.init_singleton *args
    @@singleton = SugesterQueue.new *args
  end


  def self.singleton_initialized?
    assert("uninitialized singleton. run Sugester.init_singleton", @@singleton)
  end

  def self.activity(*args)
    singleton_initialized?
    @@singleton.activity(*args)
  end

  def self.property(*args)
    singleton_initialized?
    @@singleton.property(*args)
  end

  def self.payment(*args)
    singleton_initialized?
    @@singleton.payment(*args)
  end

end
