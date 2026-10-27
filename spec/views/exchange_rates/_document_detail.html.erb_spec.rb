require 'spec_helper'

RSpec.describe 'exchange_rates/_document_detail', type: :view do
  subject { render }

  let(:period) { build(:exchange_rate_period, has_exchange_rates: true) }
  let(:rate_type) { 'spot' }

  before do
    allow(view).to receive(:period) { period }
    allow(view).to receive_messages(type: rate_type, type_label: rate_type)
  end

  it { is_expected.to have_css 'h3', text: "June #{period.year} spot exchange rates" }

  it { is_expected.to have_link('CSV', href: '/exchange_rates/view/files/exrates-monthly-0623.csv', count: 2) }

  it { is_expected.to have_link('View online', href: "/exchange_rates/view/#{period.year}-#{period.month}?type=spot") }

  it { is_expected.to have_css '.downloads .attachment-thumb img[src*="spreadsheet"]' }

  %w[spot average monthly].each do |type|
    context "with #{type} rates" do
      let(:rate_type) { type }

      it 'links the document thumbnail to the selected rate type and period' do
        expect(subject).to have_css(
          ".attachment-thumb a[href='/exchange_rates/view/#{period.year}-#{period.month}?type=#{rate_type}'] img",
        )
      end
    end
  end

  context 'when the period has no exchange rates' do
    let(:period) { build(:exchange_rate_period, has_exchange_rates: false) }

    it 'shows the document thumbnail without a link' do
      expect(subject).to have_css '.attachment-thumb img[src*="spreadsheet"]'
      expect(subject).not_to have_css '.attachment-thumb a'
    end
  end

  it { is_expected.to have_css 'p', text: 'This file may not be suitable for users of assistive technology' }

  it { is_expected.to have_css 'details', text: 'Request an accessible format.' }
end
