require 'spec_helper'

RSpec.describe 'Error handling' do
  subject { page }

  shared_examples 'not found' do
    it { is_expected.to have_http_status :not_found }
    it { is_expected.to have_css '.govuk-main-wrapper h1', text: 'Page not found' }
  end

  shared_examples 'internal server error' do
    it { is_expected.to have_http_status :internal_server_error }
    it { is_expected.to have_css '.govuk-main-wrapper h1', text: 'We are experiencing technical difficulties' }
  end

  shared_examples 'service unavailable' do
    it { is_expected.to have_http_status :service_unavailable }
    it { is_expected.to have_css '.govuk-main-wrapper h1', text: 'Maintenance' }
  end

  describe 'not found page' do
    before { visit '/404' }

    it_behaves_like 'not found'
  end

  describe 'exception page' do
    before { visit '/500' }

    it_behaves_like 'internal server error'
  end

  describe 'maintenance mode' do
    before { visit '/503' }

    it_behaves_like 'service unavailable'
  end

  describe 'rescued exceptions' do
    include_context 'with rescued exceptions'

    context 'with unknown url' do
      before { visit '/unknown' }

      it_behaves_like 'not found'
    end

    context 'with non existant resource' do
      before do
        stub_api_request('/news_items/9999', backend: 'uk')
          .and_return jsonapi_error_response(404)

        visit '/news/9999'
      end

      it_behaves_like 'not found'
    end

    context 'with faraday connection error' do
      before do
        stub_api_request('/news_items/9999', backend: 'uk').to_timeout

        visit '/news/9999'
      end

      it_behaves_like 'internal server error'
    end

    context 'with other error' do
      before do
        allow(NewsItem).to \
          receive(:find).and_raise(StandardError, 'Something went wrong')

        visit '/news/9999'
      end

      it_behaves_like 'internal server error'
    end

    context 'with feature that is unavailble' do
      before do
        allow(NewsItem).to \
          receive(:find).and_raise(TradeTariffFrontend::FeatureUnavailable)

        visit '/news/9999'
      end

      it_behaves_like 'not found'
    end
  end
end
