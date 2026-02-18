require 'spec_helper'

RSpec.describe 'Page banner' do
  subject { page }

  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  context 'without locale prefix' do
    before { visit '/find_commodity' }

    it { is_expected.to have_css '.govuk-service-navigation__service-name a', text: 'UK Integrated Online Tariff' }
  end

  context 'with invalid locale prefix' do
    before { visit '/fr/find_commodity' }

    it { is_expected.to have_css '.govuk-service-navigation__service-name a', text: 'UK Integrated Online Tariff' }
  end

  context 'with invalid locale param' do
    before { visit '/find_commodity?locale=fr' }

    it { is_expected.to have_css '.govuk-service-navigation__service-name a', text: 'UK Integrated Online Tariff' }
  end

  context 'with service prefix' do
    before { visit '/xi/find_commodity' }

    it { is_expected.to have_css '.govuk-service-navigation__service-name a', text: 'Northern Ireland Online Tariff' }
  end
end
