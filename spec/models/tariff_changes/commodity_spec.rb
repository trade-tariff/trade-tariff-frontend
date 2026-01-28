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

    it 'responds to validity_end_date' do
      expect(commodity).to respond_to(:validity_end_date)
    end
  end

  describe '#validity_end_date' do
    context 'when validity_end_date is set as a string' do
      it 'converts to date' do
        commodity.validity_end_date = '2024-12-31'
        expect(commodity.validity_end_date).to eq(Date.new(2024, 12, 31))
      end
    end

    context 'when validity_end_date is set as a datetime' do
      it 'converts to date' do
        datetime = Time.zone.local(2024, 12, 31, 10, 30, 0)
        commodity.validity_end_date = datetime
        expect(commodity.validity_end_date).to eq(Date.new(2024, 12, 31))
      end
    end

    context 'when validity_end_date is already a date' do
      it 'returns the date unchanged' do
        date = Date.new(2024, 12, 31)
        commodity.validity_end_date = date
        expect(commodity.validity_end_date).to eq(date)
      end
    end

    context 'when validity_end_date is nil' do
      it 'returns nil' do
        commodity.validity_end_date = nil
        expect(commodity.validity_end_date).to be_nil
      end
    end
  end
end
