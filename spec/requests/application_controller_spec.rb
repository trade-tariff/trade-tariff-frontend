RSpec.describe ApplicationController, type: :request do
  describe 'GET #index' do
    subject(:do_response) { get('/healthcheck') && response }

    context 'when a handled error is raised' do
      before { allow(Section).to receive(:all).and_raise(exception) }

      let(:exception) { ActionController::InvalidAuthenticityToken }

      it { is_expected.to have_http_status(422) }
      it { expect(do_response.body).to include('Unprocessable content') }
    end

    context 'when a bad request error is raised' do
      before { allow(Section).to receive(:all).and_raise(exception) }

      let(:exception) { ActionController::BadRequest }

      it { is_expected.to have_http_status(:bad_request) }
    end

    context 'when an invalid parameter error is raised' do
      before { allow(Section).to receive(:all).and_raise(exception) }

      let(:exception) { ActionDispatch::InvalidParameterError }

      it { is_expected.to have_http_status(:bad_request) }
    end

    context 'when an invalid MIME type is raised' do
      before { allow(Section).to receive(:all).and_raise(exception) }

      let(:exception) { ActionDispatch::Http::MimeNegotiation::InvalidType }

      it { is_expected.to have_http_status(:bad_request) }
    end

    context 'when request parameter parsing fails' do
      before { allow(Section).to receive(:all).and_raise(exception) }

      let(:exception) { ActionDispatch::Http::Parameters::ParseError.new('invalid request parameters') }

      it { is_expected.to have_http_status(:bad_request) }
    end
  end
end
