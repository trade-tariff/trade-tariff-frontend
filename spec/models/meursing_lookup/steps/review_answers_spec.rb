require 'spec_helper'

RSpec.describe MeursingLookup::Steps::ReviewAnswers do
  subject(:step) { described_class.new(wizard, store) }

  let(:wizard) { MeursingLookup::Wizard.new(store, 'review_answers') }
  let(:store) { WizardSteps::Store.new({}) }

  it { is_expected.to be_a(WizardSteps::Step) }
end
