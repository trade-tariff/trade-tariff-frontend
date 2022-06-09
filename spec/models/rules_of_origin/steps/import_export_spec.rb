require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ImportExport do
  include_context 'with rules of origin store', :with_chosen_scheme
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it { is_expected.to respond_to :import_or_export }

  describe '#validation' do
    context 'with import' do
      let(:attributes) { { import_or_export: 'import' } }

      it { is_expected.to be_valid }
    end

    context 'with export' do
      let(:attributes) { { import_or_export: 'export' } }

      it { is_expected.to be_valid }
    end

    context 'with something else' do
      let(:attributes) { { import_or_export: 'random' } }

      it { is_expected.not_to be_valid }
    end

    context 'when blank' do
      it { is_expected.not_to be_valid }
    end
  end

  describe '#skipped?' do
    subject { instance.skipped? }

    it { is_expected.to be false }

    context 'with GSP selected' do
      let(:schemes) { build_list :rules_of_origin_scheme, 2, unilateral: true }

      it { is_expected.to be true }
    end
  end
end
