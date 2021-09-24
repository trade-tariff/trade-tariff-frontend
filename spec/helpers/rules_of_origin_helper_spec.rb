require 'spec_helper'

RSpec.describe RulesOfOriginHelper, type: :helper do
  describe '#rules_of_origin_service_name' do
    subject { helper.rules_of_origin_service_name }

    before do
      allow(TradeTariffFrontend::ServiceChooser).to \
        receive(:service_choice).and_return(service)
    end

    context 'with uk service' do
      let(:service) { 'uk' }

      it { is_expected.to eql 'UK' }
    end

    context 'with xi service' do
      let(:service) { 'xi' }

      it { is_expected.to eql 'EU' }
    end
  end

  describe '#rules_of_origin_schemes_intro' do
    subject { helper.rules_of_origin_schemes_intro(country_name, schemes) }

    let(:country_name) { 'France' }

    context 'with no scheme' do
      let(:schemes) { [] }

      it { is_expected.to have_css '#rules-of-origin__intro--no-scheme' }
      it { is_expected.not_to have_css '#rules-of-origin__intro--bloc-scheme' }
      it { is_expected.not_to have_css '#rules-of-origin__intro--country-scheme' }
    end

    context 'with bloc scheme' do
      let(:schemes) { build_list :rules_of_origin_scheme, 1, countries: %w[FR ES] }

      it { is_expected.not_to have_css '#rules-of-origin__intro--no-scheme' }
      it { is_expected.to have_css '#rules-of-origin__intro--bloc-scheme' }
      it { is_expected.not_to have_css '#rules-of-origin__intro--country-scheme' }
    end

    context 'with country scheme' do
      let(:schemes) { build_list :rules_of_origin_scheme, 1, countries: %w[FR] }

      it { is_expected.not_to have_css '#rules-of-origin__intro--no-scheme' }
      it { is_expected.not_to have_css '#rules-of-origin__intro--bloc-scheme' }
      it { is_expected.to have_css '#rules-of-origin__intro--country-scheme' }
    end
  end
end
