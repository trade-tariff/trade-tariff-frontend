require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ProofVerification do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be false }

    context "when 'wholly_obtained' set to 'yes'" do
      include_context 'with rules of origin store', :wholly_obtained

      it { is_expected.to be false }
    end

    context "when 'wholly_obtained' set to 'no'" do
      include_context 'with rules of origin store', :not_wholly_obtained

      it { is_expected.to be true }
    end
  end

  it_behaves_like 'an article accessor', :verification_text, 'verification'
end
