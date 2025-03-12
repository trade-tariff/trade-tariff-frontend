RSpec.describe ApplicationController, type: :request do
  describe 'GET #index' do
    subject(:do_response) { get('/healthcheck') && response }

    context 'when a handled error is raised' do
      before { allow(Section).to receive(:all).and_raise(exception) }

      let(:exception) { ActionController::InvalidAuthenticityToken }

      it { is_expected.to have_http_status(422) }
      it { expect(do_response.body).to include('Unprocessable entity') }
    end
  end
end
