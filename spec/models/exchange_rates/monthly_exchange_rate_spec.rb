RSpec.describe ExchangeRates::MonthlyExchangeRate, vcr: { cassette_name: 'exchange_rates#monthly_exchange_rates' } do
  subject(:monthly_exchange_rate) { described_class.find('2023-9') }

  it { is_expected.to have_attributes(month: '9', year: '2023') }

  describe '#month_name' do
    it { expect(monthly_exchange_rate.month_name).to eq('September') }
  end

  describe '#month_and_year_name' do
    it { expect(monthly_exchange_rate.month_and_year_name).to eq('September 2023') }
  end

  describe '#published_date' do
    it { expect(monthly_exchange_rate.published_date).to eq('23 Aug 2023') }
  end

  describe '#exchange_rates' do
    it { expect(monthly_exchange_rate.exchange_rates).to all(be_a(ExchangeRates::ExchangeRate)) }
  end

  describe '#exchange_rate_files' do
    it { expect(monthly_exchange_rate.exchange_rate_files).to all(be_a(ExchangeRates::File)) }
  end
end
