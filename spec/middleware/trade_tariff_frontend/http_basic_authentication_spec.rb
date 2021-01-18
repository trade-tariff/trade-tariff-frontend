require 'spec_helper'

# rubocop:disable Rails/HttpPositionalArguments
describe 'Basic Auth' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  context 'when app is not locked', vcr: { cassette_name: 'sections#index_auth_disabled' } do
    before do
      ENV['CDS_LOCKED_IP'] = nil
      ENV['IP_ALLOWLIST'] = nil
      ENV['CDS_LOCKED_AUTH'] = nil
      ENV['CDS_USER'] = nil
      ENV['CDS_PASSWORD'] = nil

      get '/sections'
    end

    it { expect(last_response.status).to eq(200) }
  end

  context 'when app is locked', vcr: { cassette_name: 'sections#index_auth_enabled' } do
    let(:correct_user) { 'user' }
    let(:wrong_user) { 'user12' }
    let(:correct_password) { 'password' }
    let(:wrong_password) { 'password12' }

    before do
      ENV['CDS_LOCKED_IP'] = nil
      ENV['IP_ALLOWLIST'] = nil
      ENV['CDS_LOCKED_AUTH'] = 'true'
      ENV['CDS_USER'] = correct_user
      ENV['CDS_PASSWORD'] = correct_password
    end

    after do
      ENV['CDS_LOCKED_IP'] = nil
      ENV['IP_ALLOWLIST'] = nil
      ENV['CDS_LOCKED_AUTH'] = nil
      ENV['CDS_USER'] = nil
      ENV['CDS_PASSWORD'] = nil
    end

    context 'with incorrect credentials' do
      before { get '/sections', {}, { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(wrong_user, wrong_password) } }

      it { expect(last_response.status).to eq(401) }
    end

    context 'with correct credentials' do
      before { get '/sections', {}, { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(correct_user, correct_password) } }

      it { expect(last_response.status).to eq(200) }
    end
  end
end
# rubocop:enable Rails/HttpPositionalArguments
