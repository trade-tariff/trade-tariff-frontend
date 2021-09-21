require 'spec_helper'

RSpec.describe MeursingLookup::Steps::Sucrose do
  it_behaves_like 'an answer step', 'sucrose' do
    describe '#current_tree' do
      let(:input_answers) { { 'starch' => '0 - 4.99' } }
      let(:tree) do
        filename = Rails.root.join('db/meursing_code_tree.json')
        JSON.parse(File.read(filename))
      end

      it { expect(step.current_tree).to eq(tree['0 - 4.99']) }
    end
  end
end
