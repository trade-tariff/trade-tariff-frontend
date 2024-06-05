# require 'spec_helper'

RSpec.describe ::GreenLanes::DetermineCategory do
  describe '.call' do
    subject { described_class.call(goods_nomenclature) }

    let(:goods_nomenclature) do
      build(:green_lanes_goods_nomenclature, applicable_category_assessments: [])
    end

    it { is_expected.to eq(:cat_3) }
  end
end
