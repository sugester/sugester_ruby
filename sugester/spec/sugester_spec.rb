
require 'spec_helper'

describe Sugester do
  subject { Sugester }

  describe '#cokolwiek' do
    let(:input) { 1 }
    let(:output) { subject.cokolwiek(input) }

    it 'hallo world test' do
      expect(output).to eq 2
    end
  end
end
