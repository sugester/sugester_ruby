require 'spec_helper'
require 'yaml'
secret = YAML.load_file("secret.yml")["secret"]

describe Sugester do
  subject { Sugester::SugesterQueue.new secret }

  describe '#push' do
  #  let(:input) { 1 }
  #  let(:output) { subject.cokolwiek(input) }
  #
  #  it 'hallo world test' do
  #    expect(output).to eq 2
  #  end
    it 'activity' do
      subject.activity 1, "test_msg"
      subject.activity 2, "test_msg"
    end
  end
end

describe Sugester do
  subject { Sugester }

  describe '#singleton' do
    it 'init_singleton' do
      subject.init_singleton secret
    end
    it 'activity' do
      subject.activity 3, "test_msg_singleton"
      subject.activity 4, "test_msg_singleton"
    end
  end

end
