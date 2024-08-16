require 'spec_helper'

RSpec.describe 'exchange_rates/index', type: :view do
  subject { render }

  let(:period_list) { build(:exchange_rate_period_list) }

  before do
    assign :period_list, period_list
  end

  it { is_expected.to have_css 'h1', text: 'Check foreign currency exchange rates' }

  it { is_expected.to have_css 'p', text: 'Check foreign currency exchange rates to calculate customs value on imported goods.' }

  it { is_expected.to render_template(partial: '_document_detail') }

  it { is_expected.to have_css 'h3', text: "June #{period_list.exchange_rate_periods.first.year} monthly exchange rates" }

  it { is_expected.to have_css 'a', text: period_list.exchange_rate_years.first.year.to_s }

  it { is_expected.to have_css 'dt', text: 'Published:' }

  it { is_expected.to have_css 'dd', text: '25 July 2023' }
end
