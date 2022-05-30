shared_context 'with govuk form builder' do
  before do
    allow(view).to receive(:default_form_builder)
                   .and_return GOVUKDesignSystemFormBuilder::FormBuilder
  end
end

shared_context 'with wizard store' do
  let(:backingstore) { {} }
  let(:wizardstore) { ::WizardSteps::Store.new backingstore }
end

shared_context 'with wizard step' do |wizard_class|
  subject { instance }

  include_context 'with wizard store'

  let(:attributes) { {} }
  let(:wizard) { wizard_class.new(wizardstore, described_class.key) }
  let(:instance) { described_class.new wizard, wizardstore, attributes }

  it { is_expected.to be_a ::WizardSteps::Step }
end
