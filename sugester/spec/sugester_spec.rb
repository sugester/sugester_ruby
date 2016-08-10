
require 'spec_helper'
require 'yaml'


local_test_conf = YAML.load_file("/Users/sugester/projects/sugester_gem/sugester/secret.yml").deep_symbolize_keys

describe Sugester do
  subject { Sugester::SugesterAws.new local_test_conf }

  describe '#push' do
  #  let(:input) { 1 }
  #  let(:output) { subject.cokolwiek(input) }
  #
  #  it 'hallo world test' do
  #    expect(output).to eq 2
  #  end
    it 'push' do
      subject.push "test_msg", nil
      subject.push "test_msg"
      subject.push "test_msg", 2
    end
  end
end

describe Sugester do
  subject { Sugester }

  describe '#singleton' do
    it 'init_singleton' do
      subject.init_singleton local_test_conf
    end
    it 'push' do
      subject.push "test_msg", nil
      subject.push "test_msg"
      subject.push "test_msg", 2
    end
  end

end
