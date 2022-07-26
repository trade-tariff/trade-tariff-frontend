require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::NotWhollyObtained do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped?' do
    subject { instance.skipped? }

    context 'when wholly obtained' do
      include_context 'with rules of origin store', :wholly_obtained

      it { is_expected.to be true }
    end

    context 'when not wholly obtained' do
      context 'when single wholly obtained rule' do
        include_context 'with rules of origin store',
                        :not_wholly_obtained,
                        scheme_traits: :single_wholly_obtained_rule

        it { is_expected.to be true }
      end

      context 'when multiple rules do' do
        include_context 'with rules of origin store', :not_wholly_obtained

        it { is_expected.to be false }
      end
    end
  end
end
