require 'spec_helper'

RSpec.describe SimplifiedProceduralCodeMeasure do
  let(:spc1) { described_class.new(attributes_for(:simplified_procedural_code_measure, validity_start_date: '2023-01-01', validity_end_date: '2023-01-31')) }
  let(:spc2) { described_class.new(attributes_for(:simplified_procedural_code_measure, validity_start_date: '2023-02-01', validity_end_date: '2023-02-28')) }
  let(:spc3) { described_class.new(attributes_for(:simplified_procedural_code_measure, validity_start_date: '2023-03-01', validity_end_date: nil)) }
  let(:spc4) { described_class.new(attributes_for(:simplified_procedural_code_measure, validity_start_date: nil, validity_end_date: '2023-04-30')) }
  let(:spc5) { described_class.new(attributes_for(:simplified_procedural_code_measure, validity_start_date: '2023-01-01', validity_end_date: '2023-01-31')) }

  describe '.validity_start_dates' do
    before { allow(described_class).to receive(:all).and_return([spc1, spc2, spc3, spc4, spc5]) }

    it 'returns an array of unique dates sorted in reverse order excluding nil dates' do
      expect(described_class.validity_start_dates).to eq(%w[2023-03-01 2023-02-01 2023-01-01])
    end
  end

  describe '.by_code' do
    before { allow(described_class).to receive(:all).and_return([spc1, spc2, spc3, spc4]) }

    it 'returns simplified procedural codes filtered by code sorted by validity start date in reverse' do
      allow(described_class).to receive(:all).with(filter: { simplified_procedural_code: '1.10'}).and_return([spc1, spc2])

      expect(described_class.by_code('1.10')).to eq([spc2, spc1])
    end
  end

  describe '.all_date_options' do
    before { allow(described_class).to receive(:all).and_return([spc1, spc2, spc3]) }

    it 'returns a hash of validity start dates and end dates' do
      expected_result = {
        '2023-01-01' => '2023-01-31',
        '2023-02-01' => '2023-02-28',
        '2023-03-01' => nil,
      }

      expect(described_class.all_date_options).to eq(expected_result)
    end

    it 'excludes measures without validity start dates' do
      allow(described_class).to receive(:all).and_return([spc1, spc4, spc3])

      expected_result = {
        '2023-01-01' => '2023-01-31',
        '2023-03-01' => nil,
      }

      expect(described_class.all_date_options).to eq(expected_result)
    end
  end

  describe '.by_date_options' do
    before { allow(described_class).to receive(:validity_start_dates).and_return(%w[2023-01-01 2023-02-01 2023-03-01]) }

    it 'returns an array of formatted date options' do
      expected_result = [
        ['1 Jan 2023', '2023-01-01'],
        ['1 Feb 2023', '2023-02-01'],
        ['1 Mar 2023', '2023-03-01'],
      ]

      expect(described_class.by_date_options).to eq(expected_result)
    end
  end
end
