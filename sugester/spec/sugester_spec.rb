require 'spec_helper'
require 'yaml'
secret = YAML.load_file("secret.yml")["secret"]

describe "valid secret" do
  subject { Sugester::SugesterQueue.new secret }
  subject { Sugester.init_singleton secret; Sugester }
  let(:err) { output(/WARNING/).to_stderr }

  describe '#push msg funs' do
    it 'activity' do
      subject.activity 1, "test_activity_msg"
      subject.activity 2, :test_activity_msg
      expect { subject.activity 1, 1 }.to err
      expect { subject.activity nil, "test_msg" }.to err
      expect { subject.activity nil, 1 }.to err
    end

    it 'property' do
      subject.property 1, {}
      subject.property 1, {a: 1, "b": 1}
      subject.property 1, {a: DateTime.now, "b": 1}
      expect { subject.property nil, nil }.to err
    end

    it 'payment' do
      d = Time.now
      d2 = DateTime.now + 1.days
      subject.payment 1, :payment_name, 1.99, d, d2
      subject.payment 3, "payment_name2", 199, d, d2
      expect{ subject.payment 3, "payment_name2", nil, d, d2 }.to err
      expect{ subject.payment 3, "payment_name2", 1, nil, d2 }.to err
      expect{ subject.payment 3, "payment_name2", 1, d, nil }.to err
    end
  end
end

describe "invalid secret" do

  let(:err) { output(/Secret corrupted/).to_stderr }

  subject {
    s = nil
    expect { s = Sugester::SugesterQueue.new "secret" }.to err
    s
  }
  subject {
    s = nil
    expect { s = Sugester.init_singleton "secret"; Sugester }.to err
    s
  }

  describe '#push msg funs' do
    it 'activity' do
      expect { subject.activity 1, "test_activity_msg" }.to err
      expect { subject.activity 2, :test_activity_msg }.to err
      expect { subject.activity 1, 1 }.to err
      expect { subject.activity nil, "test_msg" }.to err
      expect { subject.activity nil, 1 }.to err
    end

    it 'property' do
      expect { subject.property 1, {} }.to err
      expect { subject.property 1, {a: 1, "b": 1} }.to err
      expect { subject.property 1, {a: DateTime.now, "b": 1} }.to err
      expect { subject.property nil, nil }.to err
    end

    it 'payment' do
      d = Time.now
      d2 = DateTime.now + 1.days
      expect { subject.payment 1, :payment_name, 1.99, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", 199, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", nil, d, d2 }.to err
      expect { subject.payment 3, "payment_name2", 1, nil, d2 }.to err
      expect { subject.payment 3, "payment_name2", 1, d, nil }.to err
    end
  end
end
