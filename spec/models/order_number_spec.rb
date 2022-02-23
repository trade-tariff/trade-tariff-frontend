require 'spec_helper'

RSpec.describe OrderNumber do
  subject(:order_number) { definition.order_number }

  let(:definition) { build(:definition) }

  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        definition
        geographical_area
        geographical_areas
      ]
    end

    it { expect(described_class.relationships).to eq(expected_relationships) }
  end

  describe '#id' do
    it { expect(order_number.id).to eq("#{definition.id}-order-number-#{order_number.number}") }
  end

  describe '#definition' do
    context 'when built with a definition' do
      subject(:order_number) { build(:order_number, definition: attributes_for(:definition)) }

      it { expect(order_number.definition).to be_a(OrderNumber::Definition) }
    end

    context 'when built without a definition' do
      subject(:order_number) { build(:order_number) }

      it { expect(order_number.definition).to eq(nil) }
    end

    context 'when cast by a definition' do
      subject(:order_number) { definition.order_number }

      let(:definition) { build(:definition) }

      it { expect(order_number.definition).to eq(definition) }
    end

    context 'when built via a measure without a definition' do
      subject(:order_number) { measure.order_number }

      let(:measure) { build(:measure, order_number: attributes_for(:order_number)) }

      it { expect(order_number.definition).to eq(nil) }
    end
  end
end
