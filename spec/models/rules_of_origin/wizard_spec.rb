require 'spec_helper'

RSpec.describe RulesOfOrigin::Wizard do
  subject(:instance) { described_class.new(store, 'import_export') }

  let(:store) { build :rules_of_origin_wizard_store }

  describe '#sections' do
    subject(:sections) { instance.sections }

    it { is_expected.to all be_instance_of RulesOfOrigin::SidebarSection }
    it { expect(sections.map(&:name)).to eql %w[details originating proofs] }
  end
end
