require 'spec_helper'

RSpec.describe SimplifiedProceduralCodeMeasure do
  describe '#no_data?' do
    subject(:measure) { build(:simplified_procedural_code_measure, duty_amount:) }

    context 'when the measure has a duty amount' do
      let(:duty_amount) { nil }

      it { is_expected.to be_no_data }
    end

    context 'when the measure does not have a duty amount' do
      let(:duty_amount) { 1.0 }

      it { is_expected.not_to be_no_data }
    end
  end

  describe '#sensible_date_range?' do
    subject(:measure) { build(:simplified_procedural_code_measure, validity_start_date:, validity_end_date:) }

    context 'when the measure has no validity start date' do
      let(:validity_start_date) { nil }
      let(:validity_end_date) { '2023-01-31' }

      it { is_expected.not_to be_sensible_date_range }
    end

    context 'when the measure has no validity end date' do
      let(:validity_start_date) { '2023-01-01' }
      let(:validity_end_date) { nil }

      it { is_expected.not_to be_sensible_date_range }
    end

    context 'when the measure has a validity start date and a validity end date and the distance between the dates is less than 12 days' do
      let(:validity_start_date) { '2023-01-01' }
      let(:validity_end_date) { '2023-01-11' }

      it { is_expected.not_to be_sensible_date_range }
    end

    context 'when the measure has a validity start date and a validity end date' do
      let(:validity_start_date) { '2023-01-01' }
      let(:validity_end_date) { '2023-01-31' }

      it { is_expected.to be_sensible_date_range }
    end
  end

  describe '#presented_monetary_unit' do
    subject(:presented_monetary_unit) { build(:simplified_procedural_code_measure, monetary_unit_code:).presented_monetary_unit }

    context 'when the monetary unit code is GBP' do
      let(:monetary_unit_code) { 'GBP' }

      it { is_expected.to eq('£') }
    end

    context 'when the monetary unit code is EUR' do
      let(:monetary_unit_code) { 'EUR' }

      it { is_expected.to eq('€') }
    end
  end

  describe '.by_code' do
    let(:first_measure) { build(:simplified_procedural_code_measure, validity_start_date: '2023-01-01', validity_end_date: '2023-01-31') }
    let(:second_measure) { build(:simplified_procedural_code_measure, validity_start_date: '2023-02-01', validity_end_date: '2023-02-28') }

    before { allow(described_class).to receive(:all).and_return([first_measure, second_measure]) }

    it { expect(described_class.by_code('1.10')).to eq([second_measure, first_measure]) }
  end

  describe '.by_validity_start_and_end_date' do
    let(:measure) { described_class.new(attributes_for(:simplified_procedural_code_measure, validity_start_date: '2023-01-01', validity_end_date: '2023-01-31')) }

    before { allow(described_class).to receive(:all).with(filter: { from_date: '2023-01-01', to_date: '2023-01-31' }).and_return([measure]) }

    it { expect(described_class.by_validity_start_and_end_date('2023-01-01', '2023-01-31')).to eq([measure]) }
  end
end
