require 'spec_helper'

RSpec.describe MeursingLookup::Steps::MilkFat do
  it_behaves_like 'an answer step', 'milk_fat' do
    describe '#current_meursing_code_level' do
      let(:input_answers) do
        {
          'starch' => '0 - 4.99',
          'sucrose' => '0 - 4.99',
        }
      end

      let(:meursing_codes) do
        filename = Rails.root.join('db/meursing_code_tree.json')
        JSON.parse(File.read(filename))
      end

      it { expect(step.current_meursing_code_level).to eq(meursing_codes['0 - 4.99']['0 - 4.99']) }
    end
  end
end
