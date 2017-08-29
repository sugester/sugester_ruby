require 'aws-sdk'
require 'active_support/all'
require 'digest'

module Sugester

  VERSION = "0.7.2"

  def self.init_module
    @@disabled = false
    @@singleton = nil
  end
  init_module

  private

  def self.puts_warning msg
    $stderr.puts("WARNING: #{msg}, sugester #{VERSION}")
  end

  def self.assert(msg, v)
    puts_warning msg unless v
  end

  def self.instance_assert(variable_name, variable, *klasses)
    assert(
      "#{variable_name} must be instance of #{klasses.join(" or ")}",
      klasses.reduce(false){|acc, klass| acc || (variable.is_a? klass)}
    )
  end

  def self.safe_exec
    begin
      yield
    rescue StandardError => e
      puts_warning "ERROR: e.message"
      nil
    end
  end

  public

  class SugesterQueue

    def self.secret_corrupted_warning
      Sugester.puts_warning "Secret corrupted. Visit sugester to get valid data."
    end

    private

    def self.decrypt(msg)
      begin
        cipher = OpenSSL::Cipher.new('AES-128-ECB')
        cipher.decrypt()
        cipher.key = "JKLGHJFHGFUOYTIU"
        tempkey = Base64.decode64(URI.decode(msg))
        crypt = cipher.update(tempkey)
        crypt << cipher.final()
      rescue
        crypt = nil
      end
      return crypt
    end

    def config(property, throwable = false)
      JSON.parse(SugesterQueue.decrypt(@secret)).deep_symbolize_keys[property]
    rescue StandardError => e
      SugesterQueue.secret_corrupted_warning
      nil
    end


    def push(kind, client_id, msg)
      Sugester.assert "unknown kind", MSG_KINDS.include?(kind)
      Sugester.assert "client_id cannot be blank", client_id.present?
      raw_push msg.merge({
        client_id: client_id,
        kind: kind,
        vsn: VERSION,
      })
    end

    def raw_push(msg)
      #TODO max length
      if @sqs
        aws_msg = {
          queue_url: config(:url),
          message_body: msg.merge({
              token: config(:token),
              prefix: config(:prefix),
            }).to_json,
        }
        Sugester.safe_exec { @sqs.send_message aws_msg }
      else
        SugesterQueue.secret_corrupted_warning
      end
    end

    MSG_KINDS = [:activity, :property, :payment]
    public

    def disabled= v
      @enabled = !v
    end

    def initialize(secret, enabled: !Sugester.disabled)
      @enabled = enabled
      if @enabled
        @secret = secret
        c = config(:config)
        if c
          @sqs = Sugester.safe_exec { Aws::SQS::Client.new c }
        end
      end
    end

    def activity(client_id, name, options = {})
      if @enabled
        Sugester.instance_assert "name", name, String, Symbol
        push :activity, client_id, {name: name}
      end
    end

    def property(client_id, options)
      if @enabled
        #options.enum do |name, value|
        #  Sugester.instance_assert "name", name, String, Symbol
        #  Sugester.instance_assert "value", value, String, Symbol, Numeric, Time, DateTime, Date
        #end
        push :property, client_id, {options: options}
      end
    end

    def payment(client_id, name, price, date_from, date_to)
      if @enabled
        Sugester.instance_assert "date_from", date_from, Time, Date, DateTime
        Sugester.instance_assert "date_to", date_to, Time, Date, DateTime
        Sugester.instance_assert "price", price, Numeric
        Sugester.instance_assert "name", name, String, Symbol

        push :payment, client_id, {price: price, from: date_from, to: date_to, name: name}
      end
    end
  end

  def self.singleton
    @@singleton
  end

  def self.disabled
    @@disabled
  end

  def self.disabled= v
    @@disabled = v
    if @@singleton
      @@singleton.disabled = v
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
    @@singleton.activity(*args) if @@singleton
  end

  def self.property(*args)
    singleton_initialized?
    @@singleton.property(*args) if @@singleton
  end

  def self.payment(*args)
    singleton_initialized?
    @@singleton.payment(*args) if @@singleton
  end

end
