require 'spec_helper'

RSpec.describe RulesOfOrigin::Wizard do
  describe '#sections' do
    subject(:sections) { instance.sections }

    context 'with current_step in middle of wizard' do
      include_context 'with rules of origin store', 'not_wholly_obtained'

      let(:instance) { described_class.new(wizardstore, 'not_wholly_obtained') }

      it { is_expected.to all be_instance_of RulesOfOrigin::SidebarSection }
      it { expect(sections.map(&:name)).to include 'details' }
      it { expect(sections.map(&:name)).to include 'originating' }
      it { expect(sections.map(&:name)).not_to include 'proofs' }

      context 'with section steps' do
        subject { sections.find(&:current?).steps.map(&:key) }

        it { is_expected.to include 'not_wholly_obtained' }
        it { is_expected.not_to include 'cumulation' }
      end
    end

    context 'with conditional steps' do
      subject :section_step_keys do
        instance.sections.index_by(&:name)['originating'].steps.map(&:key)
      end

      include_context 'with rules of origin store', 'insufficient_processing'

      let(:instance) { described_class.new(wizardstore, 'rules_not_met') }

      it { is_expected.to include 'rules_not_met' }
      it { is_expected.not_to include 'product_specific_rules' }
    end
  end
end
