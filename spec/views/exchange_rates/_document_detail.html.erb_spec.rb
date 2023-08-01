require 'spec_helper'

RSpec.describe 'exchange_rates/_document_detail', type: :view do
  subject { render }

  let(:period) { build(:exchange_rate_period) }

  before do
    allow(view).to receive(:period) { period }
  end

  it { is_expected.to have_css 'h3', text: "June #{period.year} monthly exchange rates" }
end
