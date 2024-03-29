require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Cumulation do
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

  describe '#available_cumulation_methods' do
    let(:scheme) { instance.chosen_scheme }

    it { expect(instance.available_cumulation_methods).to eq %w[bilateral extended] }
  end

  describe '#country_codes_to_names', vcr: { cassette_name: 'geographical_areas#countries' } do
    let(:scheme) { instance.chosen_scheme }

    it { expect(instance.country_codes_to_names('bilateral')).to eq ['United Kingdom', 'Canada'] }

    context 'when EU' do
      it { expect(instance.country_codes_to_names('extended')).to eq ['the European Union Member States', 'Andorra'] }
    end
  end

  describe '#map_path' do
    let(:scheme) { instance.chosen_scheme }

    it { expect(instance.map_path).to eq "/cumulation_maps/#{scheme.scheme_code}.png" }
  end
end
