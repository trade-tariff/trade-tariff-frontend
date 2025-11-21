require 'spec_helper'

RSpec.describe TariffChanges::GroupedMeasureCommodityChange do
  subject(:grouped_measure_commodity_change) { described_class.new }

  describe 'attributes' do
    it 'responds to count' do
      expect(grouped_measure_commodity_change).to respond_to(:count)
    end
  end

  describe 'associations' do
    it 'responds to commodity' do
      expect(grouped_measure_commodity_change).to respond_to(:commodity)
    end
  end
end
