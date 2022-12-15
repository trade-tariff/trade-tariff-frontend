require 'spec_helper'

RSpec.describe 'Page banner' do
  subject { page }

  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  context 'without locale prefix' do
    before { visit '/find_commodity' }

    it { is_expected.to have_css 'header.govuk-header a', text: 'UK Integrated Online Tariff' }
  end

  context 'with locale prefix' do
    before { visit '/cy/find_commodity' }

    it { is_expected.to have_css 'header.govuk-header a', text: 'UK Integrated Online Tariff in Welsh' }
  end

  context 'with invalid locale prefix' do
    before { visit '/fr/find_commodity' }

    it { is_expected.to have_css 'header.govuk-header a', text: 'UK Integrated Online Tariff' }
  end

  context 'with invalid locale param' do
    before { visit '/find_commodity?locale=fr' }

    it { is_expected.to have_css 'header.govuk-header a', text: 'UK Integrated Online Tariff' }
  end

  context 'with service prefix' do
    before { visit '/xi/find_commodity' }

    it { is_expected.to have_css 'header.govuk-header a', text: 'Northern Ireland Online Tariff' }
  end

  context 'with locale and service prefix' do
    before { visit '/xi/cy/find_commodity' }

    it { is_expected.to have_css 'header.govuk-header a', text: 'Northern Ireland Online Tariff in Welsh' }
  end

  context 'with missing welsh translation' do
    before do
      stub_api_request('/sections').to_return jsonapi_response(:sections, [])

      visit '/cy/browse'
    end

    it { is_expected.to have_content 'Switch to the Northern Ireland Online Tariff' }
  end
end
