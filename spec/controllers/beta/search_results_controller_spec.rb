require 'spec_helper'

if TradeTariffFrontend.beta_search_enabled?
  RSpec.describe Beta::SearchResultsController, type: :controller do
    describe 'GET #show' do
      subject(:do_response) { get :show, params: { q: 'clothing', filter: { material: 'leather' } } }

      let(:search_result) { build(:search_result) }

      before do
        perform_search_service = instance_double('Beta::Search::PerformSearchService', call: search_result)
        allow(Beta::Search::PerformSearchService).to receive(:new).and_return(perform_search_service)
      end

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('beta/search_results/show') }

      it 'calls the PerformSearchService' do
        do_response

        expect(Beta::Search::PerformSearchService).to have_received(:new).with(
          { q: 'clothing', spell: '1' },
          { 'material' => 'leather' },
        )
      end
    end
  end
end
