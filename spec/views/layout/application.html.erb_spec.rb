require 'spec_helper'

RSpec.describe 'layouts/application.html.erb', type: :view do
  subject { render }

  before do
    allow(view).to receive(:cookies_policy).and_return cookies_policy
    allow(view).to receive(:is_switch_service_banner_enabled?).and_return true

    assign :search, Search.new
  end

  let(:cookies_policy) { Cookies::Policy.new }

  context 'with header banner' do
    it { is_expected.to have_css 'header.govuk-header > .hott-header-banner' }
  end
end
