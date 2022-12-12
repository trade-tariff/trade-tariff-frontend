require 'spec_helper'

RSpec.describe OrderNumber::Definition do
  subject(:definition) { build(:definition) }

  describe '#id' do
    it { expect(definition.id).to eq(definition.quota_definition_sid) }
  end

  describe '#geographical_areas' do
    it 'returns an empty array' do
      expect(definition.geographical_areas).to eq([])
    end

    context 'when the order number defines geographical areas' do
      subject(:definition) { build(:definition, order_number:) }

      let(:order_number) { attributes_for(:order_number, geographical_areas: [geographical_area]) }
      let(:geographical_area) { attributes_for(:geographical_area) }

      it 'returns the order number geographical areas' do
        expect(definition.geographical_areas.map(&:id)).to eq([geographical_area[:id]])
      end
    end

    context 'when the definition measures define geographical areas' do
      subject(:definition) { build(:definition, measures: [measure]) }

      let(:measure) { attributes_for(:measure, geographical_area:) }
      let(:geographical_area) { attributes_for(:geographical_area) }

      it 'returns the measure geographical areas' do
        expect(definition.geographical_areas.map(&:id)).to eq([geographical_area[:id]])
      end
    end
  end

  it_behaves_like 'an entity that has goods nomenclatures' do
    let(:entity) { build(:definition, measures:) }
  end

  describe 'suspension_period?' do
    subject { order_definition.suspension_period? }

    context 'with start and end dates' do
      let :order_definition do
        build :definition, suspension_period_start_date: Date.yesterday.xmlschema,
                           suspension_period_end_date: Date.tomorrow.xmlschema
      end

      it { is_expected.to be true }
    end

    context 'with only start date' do
      let :order_definition do
        build :definition, suspension_period_start_date: Date.yesterday.xmlschema,
                           suspension_period_end_date: nil
      end

      it { is_expected.to be false }
    end

    context 'with only end date' do
      let :order_definition do
        build :definition, suspension_period_start_date: nil,
                           suspension_period_end_date: Date.tomorrow.xmlschema
      end

      it { is_expected.to be false }
    end

    context 'with no start or end dates' do
      let :order_definition do
        build :definition, suspension_period_start_date: nil,
                           suspension_period_end_date: nil
      end

      it { is_expected.to be false }
    end
  end

  describe 'blocking_period?' do
    subject { definition.blocking_period? }

    context 'with start and end dates' do
      let :definition do
        build :definition, blocking_period_start_date: Date.yesterday.xmlschema,
                           blocking_period_end_date: Date.tomorrow.xmlschema
      end

      it { is_expected.to be true }
    end

    context 'with only start date' do
      let :definition do
        build :definition, blocking_period_start_date: Date.yesterday.xmlschema,
                           blocking_period_end_date: nil
      end

      it { is_expected.to be false }
    end

    context 'with only end date' do
      let :definition do
        build :definition, blocking_period_start_date: nil,
                           blocking_period_end_date: Date.tomorrow.xmlschema
      end

      it { is_expected.to be false }
    end

    context 'with no start or end dates' do
      let :definition do
        build :definition, blocking_period_start_date: nil,
                           blocking_period_end_date: nil
      end

      it { is_expected.to be false }
    end
  end

  describe '#first_goods_nomenclature_short_code' do
    subject { definition.first_goods_nomenclature_short_code }

    let(:definition) { build :definition, measures: }

    context 'without any goods nomenclatures' do
      let(:measures) { [] }

      it { is_expected.to be nil }
    end

    context 'with a goods nomenclature with a short code' do
      let :measures do
        [
          attributes_for(:measure, goods_nomenclature: commodity1),
          attributes_for(:measure, goods_nomenclature: commodity2),
        ]
      end

      let :commodity1 do
        attributes_for :commodity, resource_type: 'Commodity'
      end

      let :commodity2 do
        attributes_for :commodity, resource_type: 'Commodity'
      end

      it { is_expected.to eq commodity1[:goods_nomenclature_item_id] }
    end

    context 'with goods nomenclatures without short codes' do
      let :measures do
        [
          attributes_for(:measure, goods_nomenclature: subheading1),
          attributes_for(:measure, goods_nomenclature: subheading2),
        ]
      end

      let :subheading1 do
        attributes_for :subheading, resource_type: 'Subheading'
      end

      let :subheading2 do
        attributes_for :subheading, resource_type: 'Subheading'
      end

      it { is_expected.to be_nil }
    end

    context 'with goods nomenclatures with a mix of short codes and not' do
      let :measures do
        [
          attributes_for(:measure, goods_nomenclature: subheading),
          attributes_for(:measure, goods_nomenclature: commodity),
        ]
      end

      let :subheading do
        attributes_for :subheading, resource_type: 'Subheading'
      end

      let :commodity do
        attributes_for :commodity, resource_type: 'Commodity'
      end

      it { is_expected.to eq commodity[:goods_nomenclature_item_id] }
    end
  end
end
