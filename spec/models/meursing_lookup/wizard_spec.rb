require 'spec_helper'

RSpec.describe MeursingLookup::Wizard do
  subject(:wizard) { described_class.new(store, 'start') }

  let(:store) { WizardSteps::Store.new(input_answers) }

  let(:input_answers) do
    {
      'starch' => '0 - 4.99',
      'sucrose' => '0 - 4.99',
      'milk_fat' => '0 - 1.49',
      'milk_protein' => '0 - 2.49',
    }
  end

  describe '#answers_by_step' do
    let(:expected_answers) do
      {
        MeursingLookup::Steps::Starch => { 'starch' => '0 - 4.99' },
        MeursingLookup::Steps::Sucrose => { 'sucrose' => '0 - 4.99' },
        MeursingLookup::Steps::MilkFat => { 'milk_fat' => '0 - 1.49' },
        MeursingLookup::Steps::MilkProtein => { 'milk_protein' => '0 - 2.49' },
      }
    end

    it { expect(wizard.answers_by_step).to eq(expected_answers) }
  end

  describe '#answer_for' do
    let(:step) { MeursingLookup::Steps::Starch }

    let(:input_answers) do
      {
        'starch' => '0 - 4.99',
        'sucrose' => '0 - 4.99',
        'milk_fat' => '0 - 1.49',
        'milk_protein' => '0 - 2.49',
      }
    end

    it { expect(wizard.answer_for(step)).to eq('0 - 4.99') }
  end
end
