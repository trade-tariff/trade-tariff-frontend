RSpec.describe User do
  describe '.find' do
    subject(:response) { described_class.find(nil, token) }

    let(:token) { 'valid jwt' }

    context 'when there is no token' do
      let(:token) { nil }

      it { is_expected.to be_nil }
    end

    context 'when in development without a token' do
      let(:token) { nil }

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('MYOTT_AUTH_BYPASS').and_return(nil)
      end

      it 'keeps the existing dummy user lookup by default' do
        stub_api_request('http://localhost:3018/uk/user/users').and_return(jsonapi_response(:user, attributes_for(:user)))

        expect(response).to be_a(described_class)
      end

      context 'when the development bypass is disabled' do
        before do
          allow(ENV).to receive(:[]).with('MYOTT_AUTH_BYPASS').and_return('false')
        end

        it 'returns nil without requesting a dummy user', :aggregate_failures do
          expect(response).to be_nil
          expect(WebMock).not_to have_requested(:get, 'http://localhost:3018/uk/user/users')
        end
      end
    end

    context 'when in development with real authentication' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('MYOTT_AUTH_BYPASS').and_return('false')
        stub_api_request('http://localhost:3018/uk/user/users').and_return(jsonapi_error_response(404))
        stub_api_request('http://localhost:3018/uk/user/users', :post)
          .and_return(jsonapi_response(:user, attributes_for(:user).merge(email: 'local@example.test')))
      end

      it 'uses lookup then creation to return the real account', :aggregate_failures do
        expect(response.email).to eq('local@example.test')
        expect(WebMock).to have_requested(:post, 'http://localhost:3018/uk/user/users')
          .with(headers: { 'Authorization' => "Bearer #{token}" })
      end
    end

    context 'when response is successful' do
      before do
        stub_api_request('http://localhost:3018/uk/user/users').and_return(jsonapi_response(:user, attributes_for(:user)))
      end

      it { is_expected.to be_a described_class }
    end

    context 'when response is unauthorised' do
      before do
        stub_api_request('http://localhost:3018/uk/user/users').and_return(jsonapi_error_response(401))
      end

      it { is_expected.to be_nil }
    end

    context 'when response is unauthorized with expired error message' do
      let(:error_body) do
        {
          errors: [
            {
              code: 'expired',
              detail: 'Token has expired',
            },
          ],
        }.to_json
      end

      before do
        stub_api_request('http://localhost:3018/uk/user/users')
          .and_return(jsonapi_error_response(401, error_body))
      end

      it 'raises AuthenticationError with reason', :aggregate_failures do
        expect { described_class.find(nil, token) }
          .to raise_error(AuthenticationError) do |error|
            expect(error.reason).to eq('expired')
          end
      end
    end

    context 'when response is not found' do
      before do
        stub_api_request('http://localhost:3018/uk/user/users').and_return(jsonapi_error_response(404))
        stub_api_request('http://localhost:3018/uk/user/users', :post).and_return(jsonapi_response(:user, attributes_for(:user)))
      end

      it 'creates the user and returns it' do
        expect(response).to be_a(described_class)
      end
    end

    context 'when response is not found but create fails' do
      before do
        stub_api_request('http://localhost:3018/uk/user/users').and_return(jsonapi_error_response(404))
        stub_api_request('http://localhost:3018/uk/user/users', :post).and_return(jsonapi_error_response(401))
      end

      it 'raises the unauthorized error from create' do
        expect { response }.to raise_error(Faraday::UnauthorizedError)
      end
    end
  end

  describe '.update' do
    subject(:response) { described_class.update(token, attributes) }

    let(:token) { 'valid-jwt-token' }
    let(:attributes) { { chapter_ids: '01,02' } }

    context 'when token is nil' do
      let(:token) { nil }

      it { is_expected.to be_nil }
    end

    context 'when in development without a token and with the bypass disabled' do
      let(:token) { nil }

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('MYOTT_AUTH_BYPASS').and_return('false')
      end

      it 'does not update a dummy user', :aggregate_failures do
        expect(response).to be_nil
        expect(WebMock).not_to have_requested(:put, 'http://localhost:3018/uk/user/users')
      end
    end

    context 'when the request is successful' do
      before do
        stub_api_request('http://localhost:3018/uk/user/users', :put)
          .with(body: {
            data: {
              attributes: attributes,
            },
          })
          .and_return(jsonapi_response(:user, attributes))
      end

      it { is_expected.to be_a described_class }
      it { expect(response.chapter_ids).to eq('01,02') }
    end

    context 'when response is unauthorised' do
      before do
        stub_api_request('http://localhost:3018/uk/user/users', :put)
        .with(body: {
          data: {
            attributes: attributes,
          },
        }).and_return(jsonapi_error_response(401))
      end

      it { is_expected.to be_nil }
    end
  end
end
