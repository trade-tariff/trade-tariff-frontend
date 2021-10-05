require 'spec_helper'

RSpec.describe 'exchange rates', vcr: { cassette_name: 'exchange_rates#index' } do
  let(:monetary_exchange_rate) do
    MonetaryExchangeRate.all.last
  end

  before do
    visit exchange_rates_path
  end

  it 'displays exchange rates in tables per year' do
    expect(page).to have_content(monetary_exchange_rate.exchange_rate)
    expect(page).to have_content(monetary_exchange_rate.inverse_rate)
    expect(page).to have_content(monetary_exchange_rate.validity_start_date.strftime('%d %B %Y'))
  end

  it 'highlights latest exchange rate' do
    expect(page.find('.current-rate__accent')).to have_content("#{monetary_exchange_rate.inverse_rate} EUR")
    expect(page.find('.current-rate__inverse')).to have_content("#{monetary_exchange_rate.exchange_rate} GBP")
  end
end
