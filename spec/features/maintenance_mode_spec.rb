require 'spec_helper'

RSpec.describe 'Maintenance mode' do
  subject { page }

  shared_examples 'service unavailable' do
    it { is_expected.to have_http_status :service_unavailable }
    it { is_expected.to have_css '.govuk-main-wrapper h1', text: 'Maintenance' }
  end

  describe 'maintenance mode page' do
    context 'with html' do
      before { visit '/503' }

      it_behaves_like 'service unavailable'
    end

    context 'with json' do
      before { visit '/503.json' }

      it { is_expected.to have_http_status :service_unavailable }
      it { expect(JSON.parse(page.body)).to include 'error' => 'Maintenance mode' }
    end

    context 'with something else' do
      before { visit '/503.pdf' }

      it { is_expected.to have_http_status :service_unavailable }
      it { is_expected.to have_attributes body: 'Maintenance mode' }
    end

    context 'with broken news banner' do
      before do
        allow(News::Item).to \
          receive(:latest_banner).and_raise(StandardError, 'Something went wrong')

        visit '/503'
      end

      it_behaves_like 'service unavailable'
    end
  end

  describe 'visiting a page whilst maintenance mode is enabled' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MAINTENANCE').and_return true
    end

    context 'without bypass enabled' do
      before { visit '/news' }

      it_behaves_like 'service unavailable'
    end

    context 'with bypass enabled' do
      before do
        allow(ENV).to receive(:[]).with('MAINTENANCE_BYPASS').and_return 'bypass'
      end

      context 'without bypass param' do
        before { visit '/news' }

        it_behaves_like 'service unavailable'
      end

      context 'with wrong bypass param' do
        before { visit '/news?maintenance_bypass=something' }

        it_behaves_like 'service unavailable'
      end

      context 'with correct bypass param' do
        before do
          allow(News::Item).to receive(:updates_page).and_return []
          allow(News::Year).to receive(:all).and_return []
          allow(News::Collection).to receive(:all).and_return []

          visit '/news?maintenance_bypass=bypass'
        end

        it { is_expected.to have_http_status :success }
      end
    end
  end
end
