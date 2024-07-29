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

  describe 'not found page' do
    context 'with html' do
      before { visit '/404' }

      it_behaves_like 'not found'
    end

    context 'with json' do
      before { visit '/404.json' }

      it { is_expected.to have_http_status :not_found }
      it { expect(JSON.parse(page.body)).to include 'error' => 'Resource not found' }
    end

    context 'with something else' do
      before { visit '/404.pdf' }

      it { is_expected.to have_http_status :not_found }
      it { is_expected.to have_attributes body: 'Resource not found' }
    end
  end

  describe 'exception page' do
    context 'with html' do
      before { visit '/500' }

      it_behaves_like 'internal server error'
    end

    context 'with json' do
      before { visit '/500.json' }

      it { is_expected.to have_http_status :internal_server_error }
      it { expect(JSON.parse(page.body)).to include 'error' => 'Internal server error' }
    end

    context 'with something else' do
      before { visit '/500.pdf' }

      it { is_expected.to have_http_status :internal_server_error }
      it { is_expected.to have_attributes body: 'Internal server error' }
    end

    context 'with invalid date' do
      before { visit '/500?day=0&month=1&year=2022' }

      it_behaves_like 'internal server error'
    end
  end

  describe 'rescued exceptions' do
    context 'with unknown url' do
      before { visit '/unknown' }

      it_behaves_like 'not found'
    end

    context 'with non existent resource' do
      before do
        stub_api_request('/news/items/9999', backend: 'uk')
          .and_return jsonapi_error_response(404)

        visit '/news/9999'
      end

      it_behaves_like 'not found'
    end

    context 'with faraday connection error' do
      before do
        stub_api_request('/news/items/9999', backend: 'uk').to_timeout

        visit '/news/9999'
      end

      it_behaves_like 'internal server error'
    end

    context 'with other error' do
      before do
        allow(News::Item).to \
          receive(:find).and_raise(StandardError, 'Something went wrong')

        visit '/news/9999'
      end

      it_behaves_like 'internal server error'
    end

    context 'with broken news banner' do
      before do
        allow(News::Item).to \
          receive(:latest_banner).and_raise(StandardError, 'Something went wrong')

        visit '/news/9999'
      end

      it_behaves_like 'internal server error'
    end

    context 'with feature that is unavailable' do
      before do
        allow(News::Item).to \
          receive(:find).and_raise(TradeTariffFrontend::FeatureUnavailable)

        visit '/news/9999'
      end

      it_behaves_like 'not found'
    end
  end
end
