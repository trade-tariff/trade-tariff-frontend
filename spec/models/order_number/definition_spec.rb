require 'spec_helper'

describe OrderNumber::Definition do
  subject(:definition) { build(:definition) }

  describe '#id' do
    it { expect(definition.id).to eq(definition.quota_definition_sid) }
  end

  describe '#geographical_areas' do
    it 'returns an empty array' do
      expect(definition.geographical_areas).to eq([])
    end

    context 'when the order number defines geographical areas' do
      subject(:definition) { build(:definition, order_number: order_number) }

      let(:order_number) { attributes_for(:order_number, geographical_areas: [geographical_area]) }
      let(:geographical_area) { attributes_for(:geographical_area) }

      it 'returns the order number geographical areas' do
        expect(definition.geographical_areas.map(&:id)).to eq([geographical_area[:id]])
      end
    end

    context 'when the definition measures define geographical areas' do
      subject(:definition) { build(:definition, measures: [measure]) }

      let(:measure) { attributes_for(:measure, geographical_area: geographical_area) }
      let(:geographical_area) { attributes_for(:geographical_area) }

      it 'returns the measure geographical areas' do
        expect(definition.geographical_areas.map(&:id)).to eq([geographical_area[:id]])
      end
    end
  end
end
