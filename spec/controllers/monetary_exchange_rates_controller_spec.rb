require 'spec_helper'

RSpec.describe ExchangeRatesController, 'GET to #index', type: :controller do
  render_views

  around do |example|
    VCR.use_cassette('exchange_rates#index') do
      example.run
    end
  end

  before do
    get :index
  end

  let(:latest_rate) { MonetaryExchangeRate.all.last }

  it 'renders monetary exchange rates' do
    expect(response.body).to include latest_rate.exchange_rate
  end
end
