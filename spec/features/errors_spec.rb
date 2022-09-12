require 'spec_helper'

RSpec.describe 'Error handling' do
  subject { page }

  describe 'not found page' do
    before { visit '/404' }

    it { is_expected.to have_http_status :not_found }
    it { is_expected.to have_css '.govuk-main-wrapper h1', text: 'Page not found' }
  end

  describe 'exception page' do
    before { visit '/500' }

    it { is_expected.to have_http_status :internal_server_error }
    it { is_expected.to have_css '.govuk-main-wrapper h1', text: 'We are experiencing technical difficulties' }
  end

  describe 'maintenance mode' do
    before { visit '/503' }

    it { is_expected.to have_http_status :service_unavailable }
    it { is_expected.to have_css '.govuk-main-wrapper h1', text: 'Maintenance' }
  end
end
