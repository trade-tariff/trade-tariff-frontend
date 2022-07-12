require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::PartsComponents do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be true }

    context "when 'wholly_obtained' set to 'yes'" do
      include_context 'with rules of origin store', :wholly_obtained

      it { is_expected.to be true }
    end

    context "when 'wholly_obtained' set to 'no'" do
      include_context 'with rules of origin store', :not_wholly_obtained

      it { is_expected.to be false }
    end
  end
end
