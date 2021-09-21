require 'spec_helper'

RSpec.describe MeursingLookup::Steps::MilkFat do
  it_behaves_like 'an answer step', 'milk_fat' do
    describe '#current_tree' do
      let(:input_answers) do
        {
          'starch' => '0 - 4.99',
          'sucrose' => '0 - 4.99',
        }
      end

      let(:tree) do
        filename = Rails.root.join('db/meursing_code_tree.json')
        JSON.parse(File.read(filename))
      end

      it { expect(step.current_tree).to eq(tree['0 - 4.99']['0 - 4.99']) }
    end
  end
end
