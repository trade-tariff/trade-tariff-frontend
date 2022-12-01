require 'spec_helper'

RSpec.describe 'layouts/application', type: :view do
  subject { render }

  before do
    allow(view).to receive(:cookies_policy).and_return Cookies::Policy.new
    allow(view).to receive(:is_switch_service_banner_enabled?).and_return true
    allow(view).to receive(:beta_search_enabled?).and_return true

    assign :search, Search.new
  end

  context 'with header banner' do
    it { is_expected.to have_css 'header.govuk-header > .tariff-header-banner' }
  end
end
