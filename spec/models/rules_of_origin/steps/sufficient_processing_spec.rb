require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::SufficientProcessing do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it_behaves_like 'an article accessor',
                  :insufficient_processing_text,
                  'insufficient-processing'

  it { is_expected.to respond_to :sufficient_processing }
  it { is_expected.to have_attributes options: %w[yes no] }

  describe 'validation' do
    it { is_expected.to allow_value('yes').for :sufficient_processing }
    it { is_expected.to allow_value('no').for :sufficient_processing }
    it { is_expected.not_to allow_value('random').for :sufficient_processing }
    it { is_expected.not_to allow_value('').for :sufficient_processing }
    it { is_expected.not_to allow_value(nil).for :sufficient_processing }
  end

  describe '#skipped?' do
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
