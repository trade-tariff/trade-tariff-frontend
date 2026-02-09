RSpec.describe User do
  describe '.find' do
    subject(:response) { described_class.find(nil, token) }

    let(:token) { 'valid jwt' }

    context 'when there is no token' do
      let(:token) { nil }

      it { is_expected.to be_nil }
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
  end

  describe '.update' do
    subject(:response) { described_class.update(token, attributes) }

    let(:token) { 'valid-jwt-token' }
    let(:attributes) { { chapter_ids: '01,02' } }

    context 'when token is nil' do
      let(:token) { nil }

      it { is_expected.to be_nil }
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
