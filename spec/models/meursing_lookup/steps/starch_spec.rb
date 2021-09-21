require 'spec_helper'

RSpec.describe MeursingLookup::Steps::Starch do
  it_behaves_like 'an answer step', 'starch' do
    describe '#current_tree' do
      it { expect(step.current_tree).to eq(step.tree) }
    end
  end
end
