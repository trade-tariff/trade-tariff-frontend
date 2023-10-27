require 'spec_helper'

RSpec.describe ExchangeRatesHelper, type: :helper do
  describe '#filter_years' do
    let(:years) { build_list(:exchange_rate_year, 4) }
    let(:year_to_hide) { years.first.year }
    let(:filtered_years) { helper.filter_years(years, year_to_hide) }

    it 'removes the year to hide from the list' do
      expect(filtered_years).not_to include(year_to_hide)
    end

    it 'does not modify the original years list' do
      expect { helper.filter_years(years, year_to_hide) }.not_to(change { years })
    end

    it 'returns a new list without the year to hide' do
      expect(filtered_years.length).to eq(years.length - 1)
    end

    context 'when 2020 is in the list, it is kept hidden' do
      let(:year_2022) { build(:exchange_rate_year, year: 2022) }
      let(:years) { [build(:exchange_rate_year, year: 2020), year_2022] }
      let(:filtered_years) { helper.filter_years(years, 2021) }

      it 'contains year 2022 only' do
        expect(filtered_years).to eq([year_2022])
      end
    end
  end

  describe '#exchange_rates_page_title' do
    subject(:page_title) { helper.exchange_rates_page_title(type:, year: 2022, month:) }

    let(:month) { nil }

    context 'when type is monthly' do
      let(:type) { 'monthly' }
      let(:month) { 1 }

      it { is_expected.to eq('January 2022 HMRC monthly currency exchange rates - GOV.UK') }
    end

    context 'when the month is nil' do
      let(:month) { nil }
      let(:type) { 'monthly' }

      it { is_expected.to eq('2022 HMRC monthly currency exchange rates - GOV.UK') }
    end

    context 'when type is spot' do
      let(:type) { 'spot' }
      let(:month) { 1 }

      it { is_expected.to eq('January 2022 HMRC currency exchange spot rates - GOV.UK') }
    end

    context 'when type is average' do
      let(:type) { 'average' }

      it { is_expected.to eq('HMRC currency exchange average rates - GOV.UK') }
    end

    context 'when the type is not valid' do
      let(:type) { 'wrong-type' }

      it 'raises an exception' do
        expect { page_title }.to raise_exception("Not valid Exchage rate type: 'wrong-type'")
      end
    end
  end
end
