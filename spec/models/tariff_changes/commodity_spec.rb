require 'spec_helper'

RSpec.describe TariffChanges::Commodity do
  subject(:commodity) { described_class.new }

  describe 'attributes' do
    it 'responds to classification_description' do
      expect(commodity).to respond_to(:classification_description)
    end

    it 'responds to goods_nomenclature_item_id' do
      expect(commodity).to respond_to(:goods_nomenclature_item_id)
    end
  end
end
