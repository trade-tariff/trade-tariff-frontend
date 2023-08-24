require 'spec_helper'

RSpec.describe 'exchange_rates/show', type: :view do
  subject { render }

  before do
    assign :monthly_exchange_rate, monthly_exchange_rate
  end

  let(:monthly_exchange_rate) { build(:monthly_exchange_rate) }

  it { is_expected.to have_css 'h1', text: "#{monthly_exchange_rate.month_and_year_name} monthly exchange rates" }

  it { is_expected.to have_css 'p', text: "Official #{monthly_exchange_rate.month_and_year_name}" }

  it { is_expected.to have_css 'th', text: 'Country/territory' }
  it { is_expected.to have_css 'th', text: 'Currency' }
  it { is_expected.to have_css 'th', text: 'Currency code' }
  it { is_expected.to have_css 'th', text: 'Currency units per £1' }
  it { is_expected.to have_css 'th', text: 'Start date' }
  it { is_expected.to have_css 'th', text: 'End date' }

  it { is_expected.to have_css 'td', text: monthly_exchange_rate.exchange_rates.first.country }
  it { is_expected.to have_css 'td', text: monthly_exchange_rate.exchange_rates.first.currency_description }
  it { is_expected.to have_css 'td', text: monthly_exchange_rate.exchange_rates.first.currency_code.upcase }
  it { is_expected.to have_css 'td', text: monthly_exchange_rate.exchange_rates.first.rate }
  it { is_expected.to have_css 'td', text: monthly_exchange_rate.exchange_rates.first.formatted_validity_start_date }
  it { is_expected.to have_css 'td', text: monthly_exchange_rate.exchange_rates.first.formatted_validity_end_date }
end
