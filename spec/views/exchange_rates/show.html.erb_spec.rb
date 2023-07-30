require 'spec_helper'

RSpec.describe 'exchange_rates/show', type: :view, params: {year: 2023, month: 6} do
  subject { render }

  before do
    allow(view).to receive(:year).and_return(2023)
    allow(view).to receive(:month).and_return(6)
  end

  let(:rates_list) { build(:exchange_rates_list) }

  before do
    assign :exchange_rates_list, rates_list
    assign :month_and_year, "#{Date::MONTHNAMES[rates_list.month]} #{rates_list.year}"
  end

  it { is_expected.to have_css 'h1', text: "#{month_and_year} monthly exchange rates" }

  it { is_expected.to have_css 'p', text: "Check the official #{rates_list.year}" }

  it { is_expected.to have_css 'th', text: "Country/territory" }
  it { is_expected.to have_css 'th', text: "Currency" }
  it { is_expected.to have_css 'th', text: "Currency code" }
  it { is_expected.to have_css 'th', text: "Currency units pet £1" }
  it { is_expected.to have_css 'th', text: "Start date" }
  it { is_expected.to have_css 'th', text: "End date" }

  it { is_expected.to have_css 'td', text: "#{rates_list.exchange_rates.first.country.capitalize}" }
  it { is_expected.to have_css 'td', text: "#{rates_list.exchange_rates.first.currency_description.capitalize}" }
  it { is_expected.to have_css 'td', text: "#{rates_list.exchange_rates.first.currency_code.upcase}" }
  it { is_expected.to have_css 'td', text: "#{rates_list.exchange_rates.first.rate}" }
  it { is_expected.to have_css 'td', text: "#{rates_list.exchange_rates.first.validity_start_date&.strftime('%-d %B %Y')}" }
  it { is_expected.to have_css 'td', text: "#{rates_list.exchange_rates.first.validity_end_date&.strftime('%-d %B %Y')}" }

  it { is_expected.to have_css 'a', text: "All exchange rates for #{rates_list.exchange_rates.first.year}" }
  it { is_expected.to have_css 'a', text: "Spot rates" }
  it { is_expected.to have_css 'a', text: "Average annual rates" }
end
