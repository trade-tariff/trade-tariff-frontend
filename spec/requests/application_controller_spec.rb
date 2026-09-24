RSpec.describe ApplicationController, type: :request do
  it 'captures the request country before an earlier callback halts the request' do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('MAINTENANCE').and_return('true')
    events = []

    ActiveSupport::Notifications.subscribed(
      ->(*args) { events << ActiveSupport::Notifications::Event.new(*args) },
      'process_action.action_controller',
    ) do
      get '/news', headers: { 'CloudFront-Viewer-Country' => 'GB' }
    end

    event = events.find { |candidate| candidate.payload[:controller] == 'NewsItemsController' }

    expect(event.payload[:request_country]).to eq('gb')
  end

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
