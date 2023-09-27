require 'spec_helper'

RSpec.describe ExchangeRatesController, type: :request do
  subject { response }

  context 'when exchange rate type is "spot" and year is 2022' do
    before do
      VCR.use_cassette('exchange_rate_period_list_spot_2022') do
        get '/exchange_rates/spot?year=2022'
      end
    end

    describe 'GET exchange_rates' do
      it { is_expected.to have_http_status :success }
    end
  end

  context 'when exchange rate type is "average"' do
    before do
      get '/exchange_rates/average'
    end

    describe 'GET exchange_rates' do
      it { is_expected.to have_http_status :success }
    end
  end

  context 'when exchange rate type is NOT valid' do
    describe 'GET exchange_rates' do
      before { get '/exchange_rates/bad_type' }

      it { is_expected.to have_http_status :not_found }
    end
  end
end
