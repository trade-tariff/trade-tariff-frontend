require 'spec_helper'

describe CommoditiesHelper, type: :helper do
  let!(:commodity1) { Commodity.new(attributes_for(:commodity).stringify_keys) }
  let!(:commodity2) { Commodity.new(attributes_for(:commodity).stringify_keys) }

  let(:commodities) { [commodity1, commodity2] }

  describe '.commodity_tree' do
  end
end
