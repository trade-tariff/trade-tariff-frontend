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

  describe '#show_warning?' do
    shared_examples_for 'an order number that shows warnings' do
      subject(:show_warning?) { definition.order_number }

      it { is_expected.to be_show_warning }
    end

    shared_examples_for 'an order number that does `not` show warnings' do
      subject(:show_warning?) { definition.order_number }

      it { is_expected.not_to be_show_warning }
    end

    it_behaves_like 'an order number that shows warnings' do
      let(:definition) { build(:definition, number: '05foo', description: 'flibble') }
    end

    it_behaves_like 'an order number that does `not` show warnings' do
      let(:definition) { build(:definition, number: '05foo', description: nil) }
    end

    it_behaves_like 'an order number that does `not` show warnings' do
      let(:definition) { build(:definition, number: '041234') }
    end

    it_behaves_like 'an order number that does `not` show warnings' do
      let(:definition) { build(:definition, number: nil) }
    end

    it_behaves_like 'an order number that does `not` show warnings' do
      let(:definition) { build(:definition, number: '') }
    end
  end

  describe '#warning_text' do
    subject(:warning_text) { definition.order_number.warning_text }

    context 'when the quota definition order number has a description' do
      let(:definition) { build(:definition, number: '052000', description: 'flibble') }

      it { is_expected.to eq('flibble') }
    end
  end
end
