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
  end
end
