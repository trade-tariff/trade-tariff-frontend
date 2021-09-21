require 'spec_helper'

RSpec.describe MeursingLookup::Steps::MilkProtein do
  let(:meursing_codes) do
    filename = Rails.root.join('db/meursing_code_tree.json')
    JSON.parse(File.read(filename))
  end

  it_behaves_like 'an answer step', 'milk_protein' do
    describe '#current_meursing_code_level' do
      let(:input_answers) do
        {
          'starch' => '0 - 4.99',
          'sucrose' => '0 - 4.99',
          'milk_fat' => '0 - 1.49',
        }
      end

      it { expect(step.current_meursing_code_level).to eq(meursing_codes['0 - 4.99']['0 - 4.99']['0 - 1.49']) }
    end

    describe '#skipped?' do
      context 'when the current tree has a milk_protein_skipped key' do
        let(:input_answers) do
          {
            'starch' => '0 - 4.99',
            'sucrose' => '0 - 4.99',
            'milk_fat' => '40 - 54.99', # This key is marked as skipped in the tree
          }
        end

        it { expect(step).to be_skipped }
      end

      context 'when the current tree does not have a milk_protein_skipped key' do
        let(:input_answers) do
          {
            'starch' => '0 - 4.99',
            'sucrose' => '0 - 4.99',
            'milk_fat' => '0 - 1.49', # This key is not skipped in the tree
          }
        end

        it { expect(step).not_to be_skipped }
      end
    end
  end
end
