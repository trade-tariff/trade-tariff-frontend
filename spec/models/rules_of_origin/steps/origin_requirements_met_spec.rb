require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::OriginRequirementsMet do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be false }

    context 'when wholly_obtained' do
      include_context 'with rules of origin store', :wholly_obtained

      it { is_expected.to be false }
    end

    context 'when not wholly_obtained' do
      include_context 'with rules of origin store', :not_wholly_obtained

      it { is_expected.to be true }
    end

    context 'when not wholly_obtained and insufficiently processed' do
      include_context 'with rules of origin store', :insufficient_processing

      it { is_expected.to be true }
    end

    context 'when not wholly_obtained but sufficiently processed' do
      context 'with rules met' do
        include_context 'with rules of origin store', :rules_met

        it { is_expected.to be false }
      end

      context 'with rules not met' do
        include_context 'with rules of origin store', :rules_not_met

        it { is_expected.to be true }
      end
    end
  end

  describe 'duty_drawback_available?' do
    subject { instance.duty_drawback_available? }

    context 'with article' do
      let :articles do
        attributes_for_list :rules_of_origin_article, 1, article: 'duty-drawback'
      end

      it { is_expected.to be true }
    end

    context 'without article' do
      it { is_expected.to be false }
    end
  end

  describe 'non_alteration_available?' do
    subject { instance.non_alteration_available? }

    context 'with article' do
      let :articles do
        attributes_for_list :rules_of_origin_article, 1, article: 'non-alteration'
      end

      it { is_expected.to be true }
    end

    context 'without article' do
      it { is_expected.to be false }
    end
  end
end
