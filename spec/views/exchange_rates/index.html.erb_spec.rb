require 'spec_helper'

RSpec.describe 'exchange_rates/index', type: :view do
  subject { render }

  let(:period_list) { build(:exchange_rate_period_list) }

  before do
    assign :period_list, period_list
  end

  it { is_expected.to have_css 'h1', text: "#{period_list.year} HMRC currency exchange rates" }

  it { is_expected.to have_css 'p', text: "Check the official #{period_list.year}" }

  it { is_expected.to render_template(partial: '_document_detail') }

  it { is_expected.to have_css 'h3', text: "June #{period_list.exchange_rate_periods.first.year} monthly exchange rates" }

  it { is_expected.to have_css 'a', text: "HMRC exchange rates for #{period_list.exchange_rate_years.first.year}" }
end
