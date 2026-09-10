require 'spec_helper'

RSpec.describe 'Chapter codes requested as commodities', type: :request do
  before { TradeTariffFrontend::ServiceChooser.service_choice = nil }

  ['', '/xi'].each do |service_prefix|
    context "with the #{service_prefix.presence || 'UK'} service" do
      it 'redirects to the chapter, preserving the trade date and country' do
        get "#{service_prefix}/commodities/0100000000", params: { day: 10, month: 9, year: 2026, country: 'AD' }

        expect(response).to redirect_to("#{service_prefix}/chapters/01?country=AD&day=10&month=9&year=2026")
      end
    end
  end

  it 'loads the chapter page after redirecting a padded chapter code', :aggregate_failures do
    get '/commodities/0100000000'

    expect(response).to redirect_to('/chapters/01')

    VCR.use_cassette('geographical_areas#countries') do
      VCR.use_cassette('chapters#show') do
        follow_redirect!
      end
    end

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Live animals')
  end
end
