
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
      subject.push "test msg"
    end
  end
end
