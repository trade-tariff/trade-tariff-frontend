require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ImportExport do
  include_context 'with rules of origin store', :with_chosen_scheme
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it { is_expected.to respond_to :import_or_export }

  describe 'validation' do
    it { is_expected.to allow_value('import').for :import_or_export }
    it { is_expected.to allow_value('export').for :import_or_export }
    it { is_expected.not_to allow_value('random').for :import_or_export }
    it { is_expected.not_to allow_value('').for :import_or_export }
    it { is_expected.not_to allow_value(nil).for :import_or_export }
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
