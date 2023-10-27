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

    context 'when type is monthly' do
      let(:type) { 'monthly' }
      let(:month) { 1 }

      it { is_expected.to eq('January 2022 HMRC currency exchange monthly rates - GOV.UK') }
    end

    context 'when the month and year are nil' do
      let(:month) { nil }
      let(:year) { nil }
      let(:type) { 'spot' }

      it { is_expected.to eq('2022 HMRC currency exchange spot rates - GOV.UK') }
    end
  end

  describe '#exchange_rates_meta_description' do
    subject(:page_title) { helper.exchange_rates_meta_description(type:, year:, month:) }

    let(:type) { 'spot' }

    context 'when type is spot and year and month are present' do
      let(:month) { 2 }
      let(:year) { 2021 }

      it { is_expected.to include('February 2021') }
    end

    context 'when the month and year are nil' do
      let(:month) { nil }
      let(:year) { nil }

      it { is_expected.not_to include('February 2021') }
    end
  end
end
