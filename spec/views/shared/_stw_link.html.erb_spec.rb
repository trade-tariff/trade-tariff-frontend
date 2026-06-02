require 'spec_helper'

RSpec.describe 'shared/_stw_link', type: :view do
  subject(:rendered_page) { render_page && rendered }

  before do
    assign :search, Search.new
  end

  let :render_page do
    render 'shared/stw_link', declarable: build(:commodity)
  end

  context 'when flag single_trade_window_linking_enabled? is on' do
    before { enable_feature(:stw) }

    it { is_expected.to have_css 'div.govuk-inset-text' }
  end

  context 'when flag single_trade_window_linking_enabled? is off' do
    it { is_expected.not_to have_css 'div.govuk-inset-text' }
  end
end
