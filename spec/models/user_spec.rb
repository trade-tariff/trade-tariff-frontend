RSpec.describe User do
  describe '.find' do
    subject(:response) { described_class.find(token) }

    let(:token) { 'valid jwt' }

    context 'when there is no token' do
      let(:token) { nil }

      it { is_expected.to be_nil }
    end

    context 'when response is successful' do
      before do
        stub_api_request('/user/users').and_return(jsonapi_response(:user, attributes_for(:user)))
      end

      it { is_expected.to be_a described_class }
    end

    context 'when response is unauthorised' do
      before do
        stub_api_request('/user/users').and_return(jsonapi_error_response(401))
      end

      it { is_expected.to be_nil }
    end
  end
end
