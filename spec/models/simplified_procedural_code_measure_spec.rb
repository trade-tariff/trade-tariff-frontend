require 'spec_helper'

RSpec.describe SimplifiedProceduralCodeMeasure do
  before do
    allow(described_class).to receive(:all).and_return([spc, spc2])
  end

  let(:spc) { described_class.new(attributes_for(:simplified_procedural_code)) }
  let(:spc2) { described_class.new(attributes_for(:simplified_procedural_code, validity_start_date: from_date)) }
  let(:from_date) { '2023-02-18' }

  describe '.validity_start_dates' do
    context 'without filtering' do
      it 'returns the unique validity start dates' do
        expect(described_class.validity_start_dates).to eq(%w[2023-02-17 2023-02-18])
      end
    end

    context 'with filtering' do
      it 'returns the validity start dates within the specified date range' do
        expect(described_class).to have_received(:all).with(query: { filter: from_date: from_date } ).and_return([spc])

        expect(described_class.validity_start_dates(from_date)).to eq(['2023-02-18'])
      end
    end
  end
end
