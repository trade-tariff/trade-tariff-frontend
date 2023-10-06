RSpec.describe ExchangeRateCollection, vcr: { cassette_name: 'exchange_rates' } do
  subject(:exchange_rate_collection) { described_class.find('2023-9', filter: { type: 'monthly' }) }

  it { is_expected.to have_attributes(month: '9', year: '2023') }

  describe '#month_name' do
    it { expect(exchange_rate_collection.month_name).to eq('September') }
  end

  describe '#month_and_year_name' do
    it { expect(exchange_rate_collection.month_and_year_name).to eq('September 2023') }
  end

  describe '#published_date' do
    it { expect(exchange_rate_collection.published_date).to eq('23 Aug 2023') }
  end

  describe '#exchange_rates' do
    it { expect(exchange_rate_collection.exchange_rates).to all(be_a(ExchangeRates::ExchangeRate)) }
  end

  describe '#exchange_rate_files' do
    it { expect(exchange_rate_collection.exchange_rate_files).to all(be_a(ExchangeRates::File)) }
  end
end
