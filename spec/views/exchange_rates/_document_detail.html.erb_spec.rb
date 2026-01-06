require 'spec_helper'

RSpec.describe 'exchange_rates/_document_detail', type: :view do
  subject { render }

  let(:period) { build(:exchange_rate_period, has_exchange_rates: true) }

  before do
    allow(view).to receive(:period) { period }
    allow(view).to receive_messages(type: 'spot', type_label: 'spot')
  end

  it { is_expected.to have_css 'h3', text: "June #{period.year} spot exchange rates" }

  it { is_expected.to have_link('CSV', href: '/exchange_rates/view/files/exrates-monthly-0623.csv', count: 2) }

  it { is_expected.to have_link('View online', href: "/exchange_rates/view/#{period.year}-#{period.month}?type=spot") }
end
