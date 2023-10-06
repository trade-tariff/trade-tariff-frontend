require 'spec_helper'

RSpec.describe ExchangeRates::PeriodList, vcr: { cassette_name: 'exchange_rates#period_list' } do
  subject(:period_list) { described_class.find(year, filter: { type: :monthly }) }

  let(:year) { 2023 }

  it { is_expected.to have_attributes(year:) }

  describe '#exchange_rate_years' do
    it { expect(period_list.exchange_rate_years).to all(be_a(ExchangeRates::Year)) }
  end

  describe '#exchange_rate_periods' do
    it { expect(period_list.exchange_rate_periods).to all(be_a(ExchangeRates::Period)) }
  end

  describe '#publication_date' do
    let(:period_list) { build(:exchange_rate_period_list) }

    it 'returns the first files publication_date' do
      expect(period_list.publication_date).to eq('25 July 2023')
    end
  end
end
