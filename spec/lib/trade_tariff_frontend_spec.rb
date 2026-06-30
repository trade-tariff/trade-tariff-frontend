require 'spec_helper'

RSpec.describe TradeTariffFrontend do
  describe '.enquiries_email' do
    it 'returns the default classification enquiries email' do
      expect(described_class.enquiries_email).to eq('classification.enquiries@hmrc.gov.uk')
    end
  end

  describe '.support_email' do
    context 'with TARIFF_SUPPORT_EMAIL configured' do
      before do
        stub_const('ENV', ENV.to_hash.merge('TARIFF_SUPPORT_EMAIL' => 'configured@example.com'))
      end

      it 'returns the configured support email' do
        expect(described_class.support_email).to eq('configured@example.com')
      end
    end

    context 'without TARIFF_SUPPORT_EMAIL configured' do
      before do
        stub_const('ENV', ENV.to_hash.except('TARIFF_SUPPORT_EMAIL'))
      end

      it 'returns the default classification enquiries email' do
        expect(described_class.support_email).to eq('classification.enquiries@hmrc.gov.uk')
      end
    end
  end

  describe '.webchat_url' do
    context 'with WEBCHAT_URL configured as a full URL' do
      before do
        stub_const('ENV', ENV.to_hash.merge('WEBCHAT_URL' => 'https://example.com/webchat'))
      end

      it 'returns the configured URL' do
        expect(described_class.webchat_url).to eq('https://example.com/webchat')
      end
    end

    context 'with WEBCHAT_URL configured as a webchat slug' do
      before do
        stub_const('ENV', ENV.to_hash.merge('WEBCHAT_URL' => 'test-online-services-helpdesk'))
      end

      it 'returns the HMRC webchat URL for the slug' do
        expect(described_class.webchat_url).to eq(
          'https://www.tax.service.gov.uk/ask-hmrc/chat/test-online-services-helpdesk',
        )
      end
    end
  end

  describe '.developer_portal_url' do
    around do |example|
      described_class.instance_variable_set(:@base_domain, nil)
      example.run
      described_class.instance_variable_set(:@base_domain, nil)
    end

    context 'without DEVELOPER_PORTAL_URL configured' do
      before do
        stub_const(
          'ENV',
          ENV.to_hash.except('DEVELOPER_PORTAL_URL').merge('GOVUK_APP_DOMAIN' => 'dev.trade-tariff.service.gov.uk'),
        )
      end

      it 'returns the Developer Portal URL for the current app domain' do
        expect(described_class.developer_portal_url).to eq('https://hub.dev.trade-tariff.service.gov.uk/')
      end
    end

    context 'with DEVELOPER_PORTAL_URL configured' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DEVELOPER_PORTAL_URL' => 'http://dev.localhost:9080/'))
      end

      it 'returns the configured Developer Portal URL' do
        expect(described_class.developer_portal_url).to eq('http://dev.localhost:9080/')
      end
    end
  end

  describe '.flagsmith_api_url' do
    context 'with FLAGSMITH_API_URL configured' do
      before do
        stub_const('ENV', ENV.to_hash.merge('FLAGSMITH_API_URL' => 'https://flagsmith.example.test/api/v1'))
      end

      it 'returns the configured URL' do
        expect(described_class.flagsmith_api_url).to eq('https://flagsmith.example.test/api/v1')
      end
    end

    context 'without FLAGSMITH_API_URL configured' do
      before do
        stub_const('ENV', ENV.to_hash.except('FLAGSMITH_API_URL').merge('ENVIRONMENT' => environment))
      end

      {
        'development' => 'https://flags-edge.dev.trade-tariff.service.gov.uk/api/v1',
        'staging' => 'https://flags-edge.staging.trade-tariff.service.gov.uk/api/v1',
        'production' => 'https://flags-edge.trade-tariff.service.gov.uk/api/v1',
      }.each do |configured_environment, expected_url|
        context "when ENVIRONMENT is #{configured_environment}" do
          let(:environment) { configured_environment }

          it 'returns the Flagsmith Edge URL for that environment' do
            expect(described_class.flagsmith_api_url).to eq(expected_url)
          end
        end
      end

      context 'when ENVIRONMENT is not recognised' do
        let(:environment) { 'test' }

        it 'does not return a Flagsmith Edge URL' do
          expect(described_class.flagsmith_api_url).to be_nil
        end
      end
    end
  end

  describe '.identity_cookie_domain' do
    around do |example|
      # Clear cached values before and after each test to prevent contamination
      described_class.instance_variable_set(:@identity_cookie_domain, nil)
      described_class.instance_variable_set(:@base_domain, nil)

      example.run

      described_class.instance_variable_set(:@identity_cookie_domain, nil)
      described_class.instance_variable_set(:@base_domain, nil)
    end

    context 'when in production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      shared_examples 'returns correct domain' do |env_value, expected_domain|
        around do |example|
          original = ENV['GOVUK_APP_DOMAIN']
          ENV['GOVUK_APP_DOMAIN'] = env_value
          example.run
          ENV['GOVUK_APP_DOMAIN'] = original
        end

        it "returns '#{expected_domain}' for GOVUK_APP_DOMAIN='#{env_value}'" do
          expect(described_class.identity_cookie_domain).to eq(expected_domain)
        end
      end

      context 'with GOVUK_APP_DOMAIN set' do
        around do |example|
          original = ENV['GOVUK_APP_DOMAIN']
          ENV['GOVUK_APP_DOMAIN'] = 'https://trade-tariff.service.gov.uk'
          example.run
          ENV['GOVUK_APP_DOMAIN'] = original
        end

        it 'returns the base domain with leading dot' do
          expect(described_class.identity_cookie_domain).to eq('.trade-tariff.service.gov.uk')
        end
      end

      it_behaves_like 'returns correct domain', 'trade-tariff.service.gov.uk', '.trade-tariff.service.gov.uk'
      it_behaves_like 'returns correct domain', 'https://trade-tariff.service.gov.uk', '.trade-tariff.service.gov.uk'
      it_behaves_like 'returns correct domain', 'http://trade-tariff.service.gov.uk', '.trade-tariff.service.gov.uk'
    end

    context 'when in non-production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
      end

      it 'returns :all' do
        expect(described_class.identity_cookie_domain).to eq(:all)
      end
    end
  end

  describe '.base_domain' do
    around do |example|
      # Clear cached values before and after each test to prevent contamination
      described_class.instance_variable_set(:@identity_cookie_domain, nil)
      described_class.instance_variable_set(:@base_domain, nil)

      example.run

      described_class.instance_variable_set(:@identity_cookie_domain, nil)
      described_class.instance_variable_set(:@base_domain, nil)
    end

    context 'with GOVUK_APP_DOMAIN without protocol' do
      before do
        stub_const('ENV', ENV.to_hash.merge('GOVUK_APP_DOMAIN' => 'www.trade-tariff.service.gov.uk'))
      end

      it 'extracts the domain host' do
        expect(described_class.base_domain).to eq('www.trade-tariff.service.gov.uk')
      end
    end

    context 'with GOVUK_APP_DOMAIN with https protocol' do
      before do
        stub_const('ENV', ENV.to_hash.merge('GOVUK_APP_DOMAIN' => 'https://www.trade-tariff.service.gov.uk'))
      end

      it 'extracts the domain host' do
        expect(described_class.base_domain).to eq('www.trade-tariff.service.gov.uk')
      end
    end

    context 'with GOVUK_APP_DOMAIN with http protocol' do
      before do
        stub_const('ENV', ENV.to_hash.merge('GOVUK_APP_DOMAIN' => 'http://www.trade-tariff.service.gov.uk'))
      end

      it 'extracts the domain host' do
        expect(described_class.base_domain).to eq('www.trade-tariff.service.gov.uk')
      end
    end

    context 'with GOVUK_APP_DOMAIN including path' do
      before do
        stub_const('ENV', ENV.to_hash.merge('GOVUK_APP_DOMAIN' => 'https://www.trade-tariff.service.gov.uk/path'))
      end

      it 'extracts only the host part' do
        expect(described_class.base_domain).to eq('www.trade-tariff.service.gov.uk')
      end
    end

    context 'with GOVUK_APP_DOMAIN including port' do
      before do
        stub_const('ENV', ENV.to_hash.merge('GOVUK_APP_DOMAIN' => 'https://localhost:3000'))
      end

      it 'extracts only the host part' do
        expect(described_class.base_domain).to eq('localhost')
      end
    end
  end

  describe '.id_token_cookie_name' do
    around do |example|
      original_environment = ENV['ENVIRONMENT']
      example.run
    ensure
      ENV['ENVIRONMENT'] = original_environment
    end

    context 'when environment is production' do
      before { ENV['ENVIRONMENT'] = 'production' }

      it 'returns :id_token' do
        expect(described_class.id_token_cookie_name).to eq(:id_token)
      end
    end

    context 'when environment is staging' do
      before { ENV['ENVIRONMENT'] = 'staging' }

      it 'returns :staging_id_token' do
        expect(described_class.id_token_cookie_name).to eq(:staging_id_token)
      end
    end

    context 'when environment is development' do
      before { ENV['ENVIRONMENT'] = 'development' }

      it 'returns :development_id_token' do
        expect(described_class.id_token_cookie_name).to eq(:development_id_token)
      end
    end
  end

  describe '.refresh_token_cookie_name' do
    around do |example|
      original_environment = ENV['ENVIRONMENT']
      example.run
    ensure
      ENV['ENVIRONMENT'] = original_environment
    end

    context 'when environment is production' do
      before { ENV['ENVIRONMENT'] = 'production' }

      it 'returns :refresh_token' do
        expect(described_class.refresh_token_cookie_name).to eq(:refresh_token)
      end
    end

    context 'when environment is staging' do
      before { ENV['ENVIRONMENT'] = 'staging' }

      it 'returns :staging_refresh_token' do
        expect(described_class.refresh_token_cookie_name).to eq(:staging_refresh_token)
      end
    end

    context 'when environment is development' do
      before { ENV['ENVIRONMENT'] = 'development' }

      it 'returns :development_refresh_token' do
        expect(described_class.refresh_token_cookie_name).to eq(:development_refresh_token)
      end
    end
  end
end
