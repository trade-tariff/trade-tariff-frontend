require 'spec_helper'

RSpec.describe CommodityPresenter do
  describe '#leaf_position' do
    context 'when the commodity is not the last child' do
      subject(:presenter) { described_class.new(build(:commodity)) }

      before { allow(presenter).to receive(:last_child?).and_return(false) }

      it { expect(presenter.leaf_position).to be_nil }
    end

    context 'when the commodity is the last child' do
      subject(:presenter) { described_class.new(build(:commodity)) }

      before { allow(presenter).to receive(:last_child?).and_return(true) }

      it { expect(presenter.leaf_position).to eq(' last-child') }
    end
  end

  describe '#commodity_level' do
    subject(:presenter) { described_class.new(build(:commodity, number_indents: 3)) }

    context 'with an explicit initial_indent' do
      it 'returns a level class based on normalized indent' do
        expect(presenter.commodity_level(1)).to eq('level-3')
      end
    end

    context 'without an initial_indent (defaults to 1)' do
      it 'returns a level class using indent 1 as the base' do
        expect(presenter.commodity_level).to eq('level-3')
      end
    end

    context 'when initial_indent equals number_indents' do
      it 'returns level-1' do
        expect(presenter.commodity_level(3)).to eq('level-1')
      end
    end
  end
end
