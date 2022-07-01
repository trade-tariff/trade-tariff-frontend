require 'spec_helper'

RSpec.describe RulesOfOrigin::SidebarSection do
  subject(:instance) { described_class.new wizard, 'test', steps }

  include_context 'with rules of origin store'

  let(:wizard) { RulesOfOrigin::Wizard.new wizardstore, 'import_export' }
  let(:current_step) { wizard.find_current_step }
  let(:steps) { [current_step] }

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :steps }

  describe '#active?' do
    subject { instance.active? }

    context 'with step in this section' do
      it { is_expected.to be true }
    end

    context 'without step in this section' do
      let(:steps) { [] }

      it { is_expected.to be false }
    end
  end
end
