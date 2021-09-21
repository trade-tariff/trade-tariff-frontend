RSpec.shared_examples 'an answer step' do |answer_field|
  subject(:step) { described_class.new(wizard, store, attributes) }

  let(:wizard) { MeursingLookup::Wizard.new(store, 'starch') }
  let(:store) { WizardSteps::Store.new(input_answers) }
  let(:input_answers) { {} }
  let(:attributes) { {} }

  describe 'validations' do
    context 'when the answer attribute is present' do
      let(:attributes) { { answer_field => 'foo' } }

      it { is_expected.to be_valid }
    end

    context 'when the answer attribute is not present' do
      let(:attributes) { { answer_field => '' } }

      it { is_expected.not_to be_valid }
    end
  end
end
