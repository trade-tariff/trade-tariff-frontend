RSpec.describe ApplicationController, type: :request do
  describe 'GET #index' do
    subject(:do_response) { get('/healthcheck') && response }

    before do
      allow(Section).to receive(:all).and_raise(exception, 'foo')
    end

    context 'when the request propagates a server generated error' do
      let(:exception) { StandardError }

      it { is_expected.to have_http_status(:internal_server_error) }
      it { expect(do_response.body).to eq('{"error":"500 - Internal Server Error: Please contact the Tariff team for help with this issue."}') }
    end

    context 'when InvalidAuthenticityToken error is raised' do
      let(:exception) { ActionController::InvalidAuthenticityToken }

      it { is_expected.to have_http_status(:unprocessable_entity) }
      it { expect(do_response.body).to include('Unprocessable Entity') }
    end
  end
end
