require 'spec_helper'

RSpec.describe MeursingLookup::Steps::Start do
  subject(:step) { described_class.new(wizard, store) }

  let(:wizard) { MeursingLookup::Wizard.new(store, 'start') }
  let(:store) { WizardSteps::Store.new({}) }

  it { is_expected.to be_a(WizardSteps::Step) }
end
