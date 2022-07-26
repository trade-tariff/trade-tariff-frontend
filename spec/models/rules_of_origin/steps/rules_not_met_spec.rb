require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::RulesNotMet do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be true }

    context "when 'wholly_obtained' set to 'yes'" do
      include_context 'with rules of origin store', :sufficient_processing

      it { is_expected.to be true }
    end

    context "when 'wholly_obtained' set to 'no'" do
      include_context 'with rules of origin store', :insufficient_processing

      it { is_expected.to be false }
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
end
