require 'spec_helper'

describe MonetaryExchangeRate do
  describe '#validity_start_date' do
    it 'returns a Date object from a string' do
      rate = MonetaryExchangeRate.new(attributes_for(:monetary_exchange_rate).stringify_keys)

      expect(rate.validity_start_date).to eq Date.today.at_beginning_of_month
    end
  end

  describe '#operation_date' do
    it 'returns a Date object from a string' do
      rate = MonetaryExchangeRate.new(attributes_for(:monetary_exchange_rate).stringify_keys)

      expect(rate.operation_date).to eq Date.today.at_beginning_of_month.ago(5.days)
    end
  end

  describe '#inverse_rate' do
    it 'returns the exchange rate from GBP to EUR' do
      rate = MonetaryExchangeRate.new(attributes_for(:monetary_exchange_rate, exchange_rate: '0.8').stringify_keys)

      expect(rate.inverse_rate).to eq 1.25
    end
  end
end
