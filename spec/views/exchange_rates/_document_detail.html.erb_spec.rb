require 'spec_helper'

RSpec.describe 'exchange_rates/_document_detail', type: :view do
  subject { render }

  let(:period) { build(:exchange_rate_period) }

  before do
    allow(view).to receive(:period) { period }
  end

  it { is_expected.to have_css 'h3', text: "June #{period.year} monthly exchange rates" }

  it { is_expected.to have_link('CSV', href: '/exchange_rates/csv/exrates-monthly-0623.csv'), count: 2 }

  it { is_expected.to have_css 'p', text: 'View online | CSV 2.0 KB | CSV 2.0 KB', normalize_ws: true }
end
