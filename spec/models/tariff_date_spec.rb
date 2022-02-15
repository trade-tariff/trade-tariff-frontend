require 'spec_helper'

RSpec.describe TariffDate do
  describe '.build' do
    subject(:tariff_date) { described_class.build(date_attributes) }

    context 'when passing valid date attributes' do
      let(:date_attributes) do
        {
          'year' => '2021',
          'month' => '01',
          'day' => '02',
        }
      end

      it { is_expected.to eq(Date.parse('2021-01-02')) }
    end

    context 'when passing a invalid date attributes' do
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
