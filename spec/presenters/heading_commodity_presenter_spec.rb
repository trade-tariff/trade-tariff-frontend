require 'spec_helper'

RSpec.describe HeadingCommodityPresenter do
  describe '#root_commodities' do
    subject(:root_commodities) { described_class.new(commodities).root_commodities }

    let(:root_commodity) { OpenStruct.new(root: true) }
    let(:non_root_commodity) { OpenStruct.new(root: false) }
    let(:commodities) { [root_commodity, non_root_commodity] }

    it 'returns commodities that have root identication' do
      expect(root_commodities).to include root_commodity
    end

    it 'does not return commodity not marked as root' do
      expect(root_commodities).not_to include non_root_commodity
    end
  end

  describe '#leaf_commodities_count' do
    subject { described_class.new(heading.commodities).leaf_commodities_count }

    let(:heading) { build :heading, commodities: [standalone, parent, child, grandchild] }
    let(:standalone) { attributes_for :commodity }
    let(:parent) { attributes_for :commodity }
    let(:child) { attributes_for :commodity, parent_sid: parent[:goods_nomenclature_sid] }
    let(:grandchild) do
      attributes_for :commodity, parent_sid: child[:goods_nomenclature_sid]
    end

    it { is_expected.to be 2 }
  end
end
