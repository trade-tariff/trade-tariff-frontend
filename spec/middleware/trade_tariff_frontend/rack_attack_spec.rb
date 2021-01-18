require 'spec_helper'

describe Rack::Attack, vcr: { cassette_name: 'sections#index' } do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  context 'when app is not locked' do
    before do
      ENV['CDN_SECRET_KEY'] = nil
      ENV['CDS_LOCKED_AUTH'] = nil
      ENV['CDS_LOCKED_IP'] = nil
      ENV['CDS_PASSWORD'] = nil
      ENV['CDS_USER'] = nil
      ENV['IP_ALLOWLIST'] = nil

      get '/sections'
    end

    it { expect(last_response.status).to eq(200) }
  end

  context 'when app is locked' do
    before do
      ENV['CDN_SECRET_KEY'] = nil
      ENV['CDS_LOCKED_AUTH'] = nil
      ENV['CDS_LOCKED_IP'] = 'true'
      ENV['CDS_PASSWORD'] = nil
      ENV['CDS_USER'] = nil
      ENV['IP_ALLOWLIST'] = '127.0.0.1'
    end

    after do
      ENV['CDN_SECRET_KEY'] = nil
      ENV['CDS_PASSWORD'] = nil
      ENV['CDS_USER'] = nil
      ENV['CDS_LOCKED_AUTH'] = nil
      ENV['IP_ALLOWLIST'] = nil
      ENV['CDS_LOCKED_IP'] = nil
    end

    context 'and ip is not listed' do
      before { get '/sections', {}, { 'REMOTE_ADDR' => '1.2.3.4' } }

      it { expect(last_response.status).to eq(403) }
    end

    context 'and ip is listed' do
      before { get '/sections', {}, { 'REMOTE_ADDR' => '127.0.0.1' } }

      it { expect(last_response.status).to eq(200) }
    end
  end

  context 'when app has no CDN lock' do
    before do
      ENV['CDN_SECRET_KEY'] = nil
      ENV['IP_ALLOWLIST'] = nil

      get '/sections'
    end

    it { expect(last_response.status).to eq(200) }
  end

  context 'when app has CDN lock' do
    before do
      ENV['CDN_SECRET_KEY'] = 'CDN_SECRET_KEY'
      ENV['IP_ALLOWLIST'] = nil
    end

    after { ENV['CDN_SECRET_KEY'] = nil }

    context 'when request has no secret key header value' do
      before { get '/sections' }

      it { expect(last_response.status).to eq(403) }
    end

    context 'when request has no secret key header value but ip is allowed' do
      before do
        ENV['IP_ALLOWLIST'] = '127.0.0.1'

        get '/sections', {}, { 'REMOTE_ADDR' => '127.0.0.1' }
      end

      after { ENV['IP_ALLOWLIST'] = nil }

      it { expect(last_response.status).to eq(200) }
    end

    context 'request has wrong secret key header value' do
      before { get '/sections', {}, { 'CDN_SECRET' => 'CDN_SECRET' } }

      it { expect(last_response.status).to eq(403) }
    end

    context 'request has wrong secret key header value but ip is allowed' do
      before do
        ENV['IP_ALLOWLIST'] = '127.0.0.1'

        get '/sections', {}, { 'CDN_SECRET' => 'CDN_SECRET', 'REMOTE_ADDR' => '127.0.0.1' }
      end

      after { ENV['IP_ALLOWLIST'] = nil }

      it { expect(last_response.status).to eq(200) }
    end

    context 'request has correct secret key header value' do
      before { get '/sections', {}, { 'CDN_SECRET' => 'CDN_SECRET_KEY' } }

      it { expect(last_response.status).to eq(200) }
    end

    context 'request has correct secret key header value and ip is not in allow list' do
      before do
        ENV['IP_ALLOWLIST'] = '127.0.0.1'

        get '/sections', {}, { 'CDN_SECRET' => 'CDN_SECRET_KEY', 'REMOTE_ADDR' => '1.2.3.4' }
      end

      after { ENV['IP_ALLOWLIST'] = nil }

      it { expect(last_response.status).to eq(200) }
    end
  end
end
