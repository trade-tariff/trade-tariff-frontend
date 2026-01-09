require 'spec_helper'

RSpec.describe TradeTariffFrontend do
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
end
