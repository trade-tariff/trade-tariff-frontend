require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::PartsComponents do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be false }

    context "when 'wholly_obtained' set to 'yes'" do
      include_context 'with rules of origin store', :wholly_obtained

      it { is_expected.to be true }
    end

    context "when 'wholly_obtained' set to 'no'" do
      include_context 'with rules of origin store', :not_wholly_obtained

      it { is_expected.to be false }
    end

    context 'when not wholly obtained but only single WO rule' do
      include_context 'with rules of origin store',
                      :not_wholly_obtained,
                      scheme_traits: :single_wholly_obtained_rule

      it { is_expected.to be true }
    end
  end

  describe '#scheme_details' do
    let(:scheme) { instance.chosen_scheme }

    before do
      allow(scheme).to receive(:article)

      instance.scheme_details
    end

    context 'when importing' do
      include_context 'with rules of origin store', :not_wholly_obtained

      it { expect(scheme).to have_received(:article).with 'cumulation-import' }
    end

    context 'when exporting' do
      include_context 'with rules of origin store', :not_wholly_obtained, :exporting

      it { expect(scheme).to have_received(:article).with 'cumulation-export' }
    end
  end
end
