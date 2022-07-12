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

  describe '#exporting?' do
    subject { instance.exporting? }

    context 'with unilateral scheme so import_only' do
      include_context 'with rules of origin store', :import_only, wholly_obtained: 'no'

      let(:schemes) { build_list :rules_of_origin_scheme, 1, unilateral: true }

      it { is_expected.to be false }
    end

    context 'when importing' do
      include_context 'with rules of origin store', :importing, wholly_obtained: 'no'

      it { is_expected.to be false }
    end

    context 'when exporting' do
      include_context 'with rules of origin store', :exporting, wholly_obtained: 'no'

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
