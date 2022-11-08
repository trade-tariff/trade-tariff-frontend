require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::RulesNotMet do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it_behaves_like 'an article accessor',
                  :tolerances_text,
                  'tolerances'

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be false }

    context 'with single wholly obtained rule' do
      context 'when wholly obtained' do
        include_context 'with rules of origin store',
                        :wholly_obtained,
                        scheme_traits: :single_wholly_obtained_rule

        it { is_expected.to be true }
      end

      context 'when not wholly obtained' do
        include_context 'with rules of origin store',
                        :not_wholly_obtained,
                        scheme_traits: :single_wholly_obtained_rule

        it { is_expected.to be false }
      end
    end

    context 'with multiple rules' do
      context 'when wholly obtained' do
        include_context 'with rules of origin store', :wholly_obtained

        it { is_expected.to be true }
      end

      context 'when not wholly obtained and with insufficient processing' do
        include_context 'with rules of origin store', :insufficient_processing

        it { is_expected.to be false }
      end

      context 'when not wholly obtained with sufficient processing and meeting product specific rules' do
        include_context 'with rules of origin store', :rules_met

        it { is_expected.to be true }
      end

      context 'when not wholly obtained with sufficient processing and not meeting product specific rules' do
        include_context 'with rules of origin store', :rules_not_met

        it { is_expected.to be false }
      end
    end
  end

  describe '#first_step' do
    subject { instance.first_step }

    context 'when multiple schemes' do
      let(:schemes) { build_list :rules_of_origin_scheme, 2 }

      it { is_expected.to eql 'scheme' }
    end

    context 'when unilateral scheme' do
      let(:schemes) { build_list :rules_of_origin_scheme, 1, unilateral: true }

      it { is_expected.to eql 'import_only' }
    end

    context 'when multilateral scheme' do
      let(:schemes) { build_list :rules_of_origin_scheme, 1, unilateral: false }

      it { is_expected.to eql 'import_export' }
    end
  end

  describe '#show_cumulation_section?' do
    subject { instance.show_cumulation_section? }

    context 'when arrived via cumulation page' do
      include_context 'with rules of origin store', :not_wholly_obtained

      it { is_expected.to be true }
    end

    context 'when arrived via branch without cumulation page' do
      include_context 'with rules of origin store', :not_wholly_obtained,
                      scheme_traits: %i[single_wholly_obtained_rule]

      it { is_expected.to be false }
    end
  end
end
