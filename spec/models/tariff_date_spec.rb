require 'spec_helper'

RSpec.describe TariffDate do
  describe '.build' do
    subject(:tariff_date) { described_class.build(as_of, date_attributes) }

    let(:date_attributes) { {} }
    let(:as_of) { nil }

    context 'when passing a valid as_of' do
      let(:as_of) { '2021-01-01' }

      it { is_expected.to eq(Date.parse('2021-01-01')) }
    end

    context 'when passing an invalid as_of' do
      let(:as_of) { '2021-01-32' }

      it { is_expected.to eq(TariffUpdate.latest_applied_import_date) }
    end

    context 'when passing a nil as_of and valid date attributes' do
      let(:date_attributes) do
        {
          'year' => '2021',
          'month' => '01',
          'day' => '02',
        }
      end

      it { is_expected.to eq(Date.parse('2021-01-02')) }
    end

    context 'when passing a nil as_of and invalid date attributes' do
      let(:date_attributes) do
        {
          'month' => '01',
          'day' => '01',
        }
      end

      it { is_expected.to eq(Time.zone.today) }
    end
  end

  describe '#to_param' do
    subject(:to_param) { described_class.new(Date.parse('2021-01-01')).to_param }

    it { is_expected.to eq('2021-01-01') }
  end

  describe '#to_s' do
    subject(:tariff_date) { described_class.new(Date.parse('2021-01-01')) }

    it 'defaults to :date format when not passing a format' do
      expect(tariff_date.to_s).to eq('2021-01-01')
    end

    it 'uses the passed format when passing a format' do
      expect(tariff_date.to_s(:short)).to eq(' 1 Jan 2021')
    end
  end
end
