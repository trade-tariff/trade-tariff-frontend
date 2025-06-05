RSpec.describe DutyCalculator::Api::MonetaryExchangeRate, :user_session, type: :model do
  subject(:monetary_exchange_rate) { build(:duty_calculator_monetary_exchange_rate) }

  let(:user_session) { build(:duty_calculator_user_session) }

  it_behaves_like 'a resource that has attributes',
                  id: 'flibble',
                  child_monetary_unit_code: 'GBP',
                  operation_date: nil

  describe '#validity_start_date' do
    it { expect(monetary_exchange_rate.validity_start_date).to be_a(Date) }
  end

  describe '#exchange_rate' do
    it { expect(monetary_exchange_rate.exchange_rate).to be_a(Float) }
  end

  describe '.for' do
    let(:currency) { 'GBP' }

    context 'when the import date is not set on the session' do
      let(:user_session) { build(:duty_calculator_user_session) }

      it 'returns the latest exchange rate' do
        expect(described_class.for(currency).as_json).to eq(
          'meta' => nil,
          'id' => nil,
          'child_monetary_unit_code' => 'GBP',
          'exchange_rate' => '0.8571',
          'operation_date' => '2021-06-29',
          'validity_start_date' => '2021-07-01T00:00:00.000Z',
        )
      end
    end

    context 'when the import date is set on the session' do
      let(:user_session) { build(:duty_calculator_user_session, import_date: '2021-04-01') }

      it 'returns the exchange rate matching the month and year of the import date' do
        expect(described_class.for(currency).as_json).to eq(
          'meta' => nil,
          'id' => nil,
          'child_monetary_unit_code' => 'GBP',
          'exchange_rate' => '0.8512',
          'operation_date' => '2021-04-29',
          'validity_start_date' => '2021-04-01T00:00:00.000Z',
        )
      end
    end

    context 'when the currency we specify does not exist' do
      let(:currency) { 'SCHMKL' }

      it { expect(described_class.for(currency).as_json).to be_nil }
    end
  end
end
