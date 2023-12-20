RSpec.describe ApplicationController, type: :request do
  describe 'GET #index' do
    subject(:do_response) { get('/healthcheck') && response }

    before do
      allow(Section).to receive(:all).and_raise(exception)
    end

    context 'when AbstractController::ActionNotFound error is raised' do
      let(:exception) { AbstractController::ActionNotFound }

      it { is_expected.to have_http_status(:not_found) }
      it { expect(do_response.body).to include('not found') }
    end

    context 'when ActionController::BadRequest error is raised' do
      let(:exception) { ActionController::BadRequest }

      it { is_expected.to have_http_status(:bad_request) }
      it { expect(do_response.body).to include('Bad request') }
    end

    context 'when ActionController::NotImplemented error is raised' do
      let(:exception) { ActionController::NotImplemented }

      it { is_expected.to have_http_status(:not_implemented) }
      it { expect(do_response.body).to include('Not implemented') }
    end

    context 'when ActionController::MethodNotAllowed error is raised' do
      let(:exception) { ActionController::MethodNotAllowed }

      it { is_expected.to have_http_status(:method_not_allowed) }
      it { expect(do_response.body).to include('Method not allowed') }
    end

    context 'when ActionController::UnknownFormat error is raised' do
      let(:exception) { ActionController::MissingExactTemplate }

      it { is_expected.to have_http_status(:not_acceptable) }
      it { expect(do_response.body).to include('Not acceptable') }
    end

    context 'when InvalidAuthenticityToken error is raised' do
      let(:exception) { ActionController::InvalidAuthenticityToken }

      it { is_expected.to have_http_status(:unprocessable_entity) }
      it { expect(do_response.body).to include('Unprocessable entity') }
    end
  end
end
