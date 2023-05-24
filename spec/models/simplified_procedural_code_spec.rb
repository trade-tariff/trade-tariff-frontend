require 'spec_helper'

RSpec.describe SimplifiedProceduralCode do
  before do
    allow(described_class).to receive(:all).and_return([spc, spc2])
  end

  let(:spc) { described_class.new(attributes_for(:simplified_procedural_code)) }
  let(:spc2) { described_class.new(attributes_for(:simplified_procedural_code, validity_start_date: '2023-02-18')) }

  describe '.valid_start_dates' do
    it { expect(described_class.valid_start_dates).to eq(%w[2023-02-17 2023-02-18]) }
  end
end
