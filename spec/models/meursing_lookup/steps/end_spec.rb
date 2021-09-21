require 'spec_helper'

RSpec.describe MeursingLookup::Steps::End do
  subject(:step) { described_class.new(wizard, store) }

  let(:wizard) { MeursingLookup::Wizard.new(store, 'end') }
  let(:store) { WizardSteps::Store.new(input_answers) }

  describe '#meursing_code' do
    context 'when all answers were input' do
      let(:input_answers) do
        {
          'starch' => '0 - 4.99',
          'sucrose' => '0 - 4.99',
          'milk_fat' => '0 - 1.49',
          'milk_protein' => '0 - 2.49',
        }
      end

      it { expect(step.meursing_code).to eq('000') }
    end

    context 'when the milk protein step was skipped' do
      let(:input_answers) do
        {
          'starch' => '0 - 4.99',
          'sucrose' => '0 - 4.99',
          'milk_fat' => '40 - 54.99',
        }
      end

      it { expect(step.meursing_code).to eq('720') }
    end
  end
end
