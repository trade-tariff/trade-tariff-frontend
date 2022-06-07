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

  let(:attributes) { {} }
  let(:wizard) { wizard_class.new(wizardstore, described_class.key) }
  let(:instance) { described_class.new wizard, wizardstore, attributes }

  it { is_expected.to be_a ::WizardSteps::Step }
end

shared_context 'with rules of origin store' do |state|
  before do
    stub_api_request('/geographical_areas/JP').and_return \
      jsonapi_response :geographical_area,
                       attributes_for(:geographical_area,
                                      description: 'Japan',
                                      id: 'JP')
  end

  let(:wizardstore) { build :rules_of_origin_wizard, state }
end
