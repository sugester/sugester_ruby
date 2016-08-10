
require 'spec_helper'

describe Sugester do
  subject { Sugester.local }

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
