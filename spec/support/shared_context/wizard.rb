shared_context 'with wizard store' do
  let(:backingstore) { {} }
  let(:wizardstore) { ::WizardSteps::Store.new backingstore }
end

shared_context 'with wizard step' do |wizard_class|
  subject { instance }

  let(:attributes) { {} }
  let(:wizard) { wizard_class.new(wizardstore, described_class.key) }
  let(:instance) { described_class.new wizard, wizardstore, attributes }

  it { is_expected.to be_a ::WizardSteps::Step }
end
