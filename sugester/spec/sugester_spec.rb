require 'spec_helper'
require 'yaml'
secret_file = YAML.load_file("secret.yml")
secret = secret_file["secret"]
secret_bad_key = secret_file["secret_bad_key"]

describe "auto init_module" do
  it do
    expect( Sugester.singleton ).to eq(nil)
    expect( Sugester.disabled ).to eq(false)
  end
end

describe "AWS login bad key" do
  it do
    expect{
      Sugester.init_singleton secret_bad_key
      Sugester.activity 1, "test_activity_msg"
    }.to output(/ERROR/).to_stderr
  end
end

[
  lambda {
    Sugester.init_module
    Sugester::SugesterQueue.new secret
  },
  lambda {
    Sugester.init_module
    Sugester.init_singleton secret
    Sugester
  },
].each_with_index do |s,i|

  describe "valid secret #{i}" do

    let(:err) { output(/WARNING/).to_stderr }
    subject { s[] }

    it 'activity' do
      subject.activity 1, "test_activity_msg"
      subject.activity 2, :test_activity_msg
      subject.activity "aaa", :test_activity_msg
      expect { subject.activity 1, 1 }.to err
      expect { subject.activity nil, "test_msg" }.to err
      expect { subject.activity nil, 1 }.to err
      expect { subject.activity "", 1 }.to err
    end

    it 'property' do
      subject.property 1, {}
      subject.property 1, {a: 1, "b": 1}
      subject.property 1, {a: DateTime.now, "b": 1}
      subject.property "a1", {a: DateTime.now, "b": 1}
      expect { subject.property nil, nil }.to err
    end

    it 'payment' do
      d = Time.now
      d2 = DateTime.now + 1.days
      subject.payment 1, :payment_name, 1.99, d, d2
      subject.payment 3, "payment_name2", 199, d, d2
      subject.payment "a3", "payment_name2", 199, d, d2
      expect{ subject.payment 3, "payment_name2", nil, d, d2 }.to err
      expect{ subject.payment 3, "payment_name2", 1, nil, d2 }.to err
      expect{ subject.payment 3, "payment_name2", 1, d, nil }.to err
      expect{ subject.payment "", "payment_name2", 199, d, d2 }.to err
    end

  end
end


[
  lambda {
    Sugester.init_module
    Sugester::SugesterQueue.new "secret"
  },
  lambda {
    Sugester.init_module
    Sugester.init_singleton "secret"
    Sugester
  },
].each_with_index do |s,i|

  describe "invalid secret #{i}" do

    let(:err) { output(/Secret corrupted/).to_stderr }
    subject { x = nil ; expect{ x = s[] }.to err ; x }

    it 'activity' do
      expect { subject.activity 1, "test_activity_msg" }.to err
      expect { subject.activity 2, :test_activity_msg }.to err
      expect { subject.activity 1, 1 }.to err
      expect { subject.activity nil, "test_msg" }.to err
      expect { subject.activity nil, 1 }.to err
      expect { subject.activity "", 1 }.to err
    end

    it 'property' do
      expect { subject.property 1, {} }.to err
      expect { subject.property "", {} }.to err
      expect { subject.property 1, {a: 1, "b": 1} }.to err
      expect { subject.property 1, {a: DateTime.now, "b": 1} }.to err
      expect { subject.property nil, nil }.to err
      expect { subject.property "", nil }.to err
    end

    it 'payment' do
      d = Time.now
      d2 = DateTime.now + 1.days
      expect { subject.payment 1, :payment_name, 1.99, d, d2 }.to err
      expect { subject.payment "", :payment_name, 1.99, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", 199, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", nil, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", 1, nil, d2 }.to err
      expect { subject.payment 3, "payment_name2", 1, d, nil }.to err
    end

  end
end

[
  lambda {
    Sugester.init_module
    Sugester
  },
].each_with_index do |s,i|

  describe "uninitialized #{i}" do

    let(:err) { output(/uninitialized singleton/).to_stderr }
    subject { s[] }

    it 'activity' do
      expect { subject.activity 1, "test_activity_msg" }.to err
      expect { subject.activity 2, :test_activity_msg }.to err
      expect { subject.activity 1, 1 }.to err
      expect { subject.activity nil, "test_msg" }.to err
      expect { subject.activity nil, 1 }.to err
      expect { subject.activity "", 1 }.to err
    end

    it 'property' do
      expect { subject.property 1, {} }.to err
      expect { subject.property "", {} }.to err
      expect { subject.property 1, {a: 1, "b": 1} }.to err
      expect { subject.property 1, {a: DateTime.now, "b": 1} }.to err
      expect { subject.property nil, nil }.to err
      expect { subject.property "", nil }.to err
    end

    it 'payment' do
      d = Time.now
      d2 = DateTime.now + 1.days
      expect { subject.payment 1, :payment_name, 1.99, d, d2 }.to err
      expect { subject.payment "", :payment_name, 1.99, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", 199, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", nil, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", 1, nil, d2 }.to err
      expect { subject.payment 3, "payment_name2", 1, d, nil }.to err
    end

  end
end

[
  lambda {
    Sugester.init_module
    Sugester::SugesterQueue.new secret, enabled: false
  },
  lambda {
    Sugester.init_module
    Sugester.init_singleton secret, enabled: false
    Sugester
  },
  lambda {
    Sugester.init_module
    Sugester.init_singleton "secret", enabled: false
    Sugester
  },
  lambda {
    Sugester.init_module
    Sugester.disabled = true
    Sugester.init_singleton "secret"
    Sugester
  },
  lambda {
    Sugester.init_module
    Sugester.init_singleton secret
    Sugester.disabled = true
    Sugester
  },
].each_with_index do |s,i|

  describe "disabled #{i}" do

    let(:clean_output) { output("").to_stderr }
    subject { s[] }

    it 'activity' do
      expect {
        subject.activity 1, "test_activity_msg"
        subject.activity 2, :test_activity_msg
        subject.activity "aaa", :test_activity_msg
        subject.activity 1, 1
        subject.activity nil, "test_msg"
        subject.activity nil, 1
        subject.activity "", 1
      }.to clean_output
    end

    it 'property' do
      expect {
        subject.property 1, {}
        subject.property 1, {a: 1, "b": 1}
        subject.property 1, {a: DateTime.now, "b": 1}
        subject.property "a1", {a: DateTime.now, "b": 1}
        subject.property nil, nil
      }.to clean_output
    end

    it 'payment' do
      d = Time.now
      d2 = DateTime.now + 1.days
      expect {
        subject.payment 1, :payment_name, 1.99, d, d2
        subject.payment 3, "payment_name2", 199, d, d2
        subject.payment "a3", "payment_name2", 199, d, d2
        subject.payment 3, "payment_name2", nil, d, d2
        subject.payment 3, "payment_name2", 1, nil, d2
        subject.payment 3, "payment_name2", 1, d, nil
        subject.payment "", "payment_name2", 199, d, d2
      }.to clean_output
    end

  end
end
